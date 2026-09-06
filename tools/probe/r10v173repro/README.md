# r10v173 — ADVERSARIAL VERIFICATION of r10uvm173 (§ `pkgDefCallBindsOwnListing173`) — **ACCEPT**

**MEASUREMENT ONLY.** The official `uhdm-cmp`
(`~/git-repos/UHDM/build/bin/uhdm-cmp`, md5 `2ad8015175758e918de1789b86ef1ea5`,
byte-identical to `~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` are the
only authorities below. slang was **NOT** patched. `results/*.csv` were **READ
ONLY**; **no row was converted**; `GOLDEN_DEFER` was never set. **LHS is ALWAYS
golden (Surelog); RHS is ALWAYS ours**, in every table and every script here.

| | |
|---|---|
| BASE | `d53fbaad` |
| worktrees | `/tmp/wt_v173` (patch applied), `/tmp/wt_v173pris` (clean `d53fbaad`) |
| pristine binary | md5 `fb82059559765e79eee43ee365aa4879` — **rebuilt from scratch here and md5-identical to the implementer's** |
| patched binary | md5 `52a3bbc93edd57b0fb5a4a143252ef43` — **likewise identical** |
| both binaries | frozen `chmod 555` at `/tmp/v173_bin/{pris,pat}.bin` **before any sweep** |
| verifier surface | `tools/probe/r10v173repro/` (8 new arms + evidence) and **6 added lines** in `tools/probe/r10uvm173repro/census173.sh` (§4) |

## 1. VERDICT — ACCEPT

Every headline number in the implementer's report reproduces **bit for bit** on
independently built binaries. No shape in the grid, the corpus or the boundary
turns a pristine-right cell into a patched-wrong one on legal SystemVerilog: the
only `AWAY-GOLDEN` readings that survive a span-blind bucket-membership scoring
are **R4 wash cells**, where golden itself splits one twice-listed call between
the two twins and *neither* binary can hold both halves (§5). The production
change is therefore shipped unmodified; the two corrections below are to the
**evidence**, not to the emitter.

## 2. WHAT REPRODUCED, INDEPENDENTLY

* **Both binary md5s**, from fresh `cmake` configures in fresh worktrees.
* **Goldens** 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
* **uhdm2rtlil** `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in **both**
  modes on **both** binaries; `ct8rows` PASS against the committed baseline, and
  pristine-vs-patched PASS in both modes.
* **Surelog corpus** `937 / 567 / 48 / 19 / 10 / 3 / 2 / 1 / 1` — the identical
  histogram on both binaries; `ct8rows` **0 differing rows over 1588** against
  the committed baseline *and* pristine-vs-patched, **status AND dump columns**.
  **No row converted.** (`Tnoc` records `rc=-11` — a SIGSEGV — on **both**
  binaries and is already that row in the committed baseline: pre-existing, not
  this pass. The transient `1DUnpackedArray/testflags` rc=139 the implementer
  reported did **not** recur in any of my runs.)
* **rowheads**, all seven rows both modes: SimpleUVM **17 → 40**, and
  SeqDriver 33, Scoreboard/default 95, MiniAmiq 40, BuildUVMPkg 52,
  Earlgrey_0_1 31/32, Rggen 0 — **every other head log byte-identical**
  (`cmp` of the twelve saved head logs: 10 SAME, 2 DIFF, both SimpleUVM).
* **The head decode.** `ct173seed` reproduces exactly: seeding golden's
  DEF-listing `ref_obj(s)@403:24 #82114` moves the head to the next argument
  (`str`); seeding the ELAB one (`#22977`) changes nothing. The judge was
  pairing golden's DEF-listing body against ours elaborated.
* **The refutation of the brief's typespec framing.** `ct173cen` over the
  `uvm_is_match` / `uvm_re_match` / `uvm_glob_to_re` population: **69 cells on
  each side, 0 diff lines**, `DEF TS=0 / ELAB TS=1` on both producers.
* **The law.** `ct173bind` on SimpleUVM: golden `PKGDEF->PKGDEF 1014` /
  `PKGDEF->PKGELAB 3`; pristine `1 / 1016`; patched `1009 / 8`. `WOULDMOVE`
  1013 predicted, 1008 realised, the five unrealised being the class-qualified
  statics of R1.
* **EvalFunc's witness cell** reads `PKGDEF->PKGELAB` on golden, pristine and
  patched alike — the gate keeps the cell the old rule was read off.
* **The prediction.** `predsweep173.sh` over 956 pristine surelog databases
  names **17** rows; `byteverify SELFCHECK=1` realises **exactly those 17**
  (selfcheck 955/956). uhdm2rtlil: **20 / 1358** movers, the same ten test names
  in both modes (selfcheck 1357/1358). **Every mover predicted BY NAME before
  the patched sweep.**
* **The dump is blind.** Path-normalised, order-blind `uhdm-dump` diff of
  pristine vs patched: **0 lines** on Scoreboard/default (1 100 350 lines),
  SimpleUVM (1 103 790) and MiniAmiq (1 890 662). For Scoreboard/default that
  0-line order-blind reading *is* the coin attribution RESUME §9 requires.
* **Canaries** `ok=52 changed=0` and `ok=8 changed=0`; both `ctcan2` PASS;
  `canaudit` PASS, `FENCE-BREACH=0`. Five protected databases byte-identical in
  both modes, `SVSwitch` `4842211c4030` and `YosysVerx` `6ccda350c24a` held.
* **cmds.txt audited by binary PATH, file by file**: 1523 + 1523 surelog and
  1458 + 1458 uhdm2rtlil command lines name **only** the frozen binary of their
  own arm; **0** lines name any other `slang-uhdm`.
* **Boundary.** `LISTED=4817 PROCESSED=4817 PRODUCED_DBS=4660 MOVED_ARMS=158
  RC_DIFFS=0` (4811 committed arms + this verifier's 6; 5 of my 6 moved, the
  negative control did not — the gate can see). `armjudge173` over all 158:
  **`CMP-GREW rows=0`**, `AWAY-GOLDEN rows=13`, `EMPTY-GOLDEN rows=4`, and the
  official cmp SHRANK on exactly two — `r10buvm8repro/vfwd8.sv` **17 → 0**
  (cmp-EQUAL) and `r10v169repro/v169_o_nonparam.sv` **50 → 48**.
  Rescored on bucket membership, **11 of the 13 go to `AWAY-GOLDEN=0`** and the
  two that do not are exactly `v170_r_copies.sv` and `v169_o_nonparam.sv` — the
  two the implementer names as R4.
* **The committed controls the brief names.** uvm167's 17 arms are LISTED and
  **0 moved** (byte-identical). uvm171's return-name arms moved but score
  `AWAY-GOLDEN=0` with the cmp unchanged (`v171_a_selonly` 27/27,
  `v171_b_faces` 146/146, `v171_d_types` 3538/3538, `v171_e_import` 48/48).
  uvm169's `v169_g_control` 33/33.

## 3. THE ADVERSARIAL GRID — 8 NEW ARMS

Each arm is compiled by Surelog and by **both** frozen binaries in **both**
views, every `rc` recorded, the official cmp run per view per binary
(`GRID.r10v173.txt`). Names are unrelated to each other and to the arm letter.

| arm | the face it puts under the gate | verdict (span-blind, bucket membership) |
|---|---|---|
| `w173_p_collide.sv` | **a PACKAGE and a CLASS with the SAME NAME** (`mist`), so `mist::flare(..)` is class-qualified while the string test could read it as package-qualified; plus a genuinely package-qualified `mist::drizzle` and a wildcard-imported bare call | **TO-GOLDEN 9, AWAY 0** — patched equals golden cell for cell in **both** views; the colliding class statics never reach the loop |
| `w173_q_formals.sv` | **every formal face**: `string`, `int`, `logic[7:0]`, `real`, class handle, two typedefs, and `ref` / `output` / `inout` / value directions, each called bare and qualified, the same string actual both ways in one expression | **TO-GOLDEN 30, AWAY 0, STILL-WRONG 0** |
| `w173_r_context.sv` | **where the call sits**: return expression, actual of another call, concatenation, replication, bit/part select, array index, `foreach` body, ternary, `case` item, package-variable initializer | **TO-GOLDEN 37, AWAY 0, STILL-WRONG 0** |
| `w173_s_shadow.sv` | a formal **shadowed** by a named-block local; a package variable, a class property and a function local sharing a name; self-recursion; task; in-body method; **out-of-body** method; static method; property initializers | **TO-GOLDEN 15, AWAY 0** (multiset AWAY 2 = R3 copy count: golden lists `climb`'s body once, we list it twice) |
| `w173_t_imports.sv` | **import clones**, home and clone listings scored separately: explicit import, wildcard import, three module instances | **TO-GOLDEN 16, AWAY 2 — and both AWAY cells are R4** (§5) |
| `w173_u_negctl.sv` | **NEGATIVE CONTROL**: module subroutines, module→package call, an interface function, a `$unit` class, system calls, a generate block | **NO CELL MOVED** — all-bucket `a`-vs-`b` bind diff is **0 lines** in both views |
| `w173_v_paramcls.sv` | **parameterized classes and specializations**: a virtual base, three specializations (`#(4)`, `#(16)`, `#(32)`), a nested class, a pure-virtual override, `super.` calls — the shapes whose parent chain might not root at a package | **TO-GOLDEN 3, AWAY 0** |
| `w173_w_orders.sv` | **order, case and arity**: callee package declared LAST, mixed-case names, a package name that is a strict PREFIX of another (`Ash` / `AshPile_pkg`), functions of 0, 1 and 3 arguments, self-recursion through the longer name | **TO-GOLDEN 12, AWAY 0, STILL-WRONG 0** — the prefix does not misfire; patched holds every bucket golden holds |

The four implementer arms re-ran here and reproduced their reported numbers
(`g173_a_qual` 9/0, `g173_b_cross` 6/0, `g173_c_homes` 22/0, `g173_d_notmove`
all-bucket diff **0 lines** in both views).

## 4. CORRECTION SHIPPED — `census173.sh` DID NOT REPRODUCE ITS OWN TABLE

The pass README's §4 mover table (`SimpleUVM/Scoreboard 2016 / 0 / 17`,
`BuildUVMPkg 1978 / 0 / 30`, `SeqDriver/MiniAmiq 434 / 0 / 2417`,
`Earlgrey_0_1 98 / 0 / 0`) is the **span-blind MULTISET** reading
(`score173.py --nospan`), and every one of those numbers reproduces here
exactly. But the committed `census173.sh` — the driver §9 tells an operator to
run — scored with `--setmode` and **no** `--nospan`, which prints

```
SimpleUVM  default  TO-GOLDEN=374  AWAY-GOLDEN=4   STILL-WRONG=21
SeqDriver  default  TO-GOLDEN=185  AWAY-GOLDEN=19  STILL-WRONG=23
Earlgrey_0_1 default TO-GOLDEN=92  AWAY-GOLDEN=6   STILL-WRONG=6
EvalFuncNamed default TO-GOLDEN=3  AWAY-GOLDEN=1   STILL-WRONG=0
```

— apparently contradicting "**Every mover scores `AWAY-GOLDEN = 0`**", with no
way for the reader to tell an evidence mismatch from a regression. **Fixed
here, additively**: `census173.sh` now prints a `NOSPAN` line (the README's
number) *and* a `SETMODE` line (bucket membership) for every row, with the
comment naming what each residual cell is. Six lines added, nothing removed, no
production code touched, no gate re-run needed.

Under the two scorings the residuals decompose cleanly: SimpleUVM's 4 and
Earlgrey's 6 are **span** artifacts (R2, `uvm_hdl_concat2string`'s macro
buffers — no generated `Compare` reads a span, so the judge cannot see them),
and SeqDriver's / MiniAmiq's 10 and EvalFuncNamed's 1 are **R4**.

## 5. RESIDUE R4 IS CORPUS-WIDE, NOT "TWO BOUNDARY ROWS"

The pass README calls R4 "the two boundary rows that stay AWAY on bucket
membership". Measured on the corpus it is larger, and it is the *only* thing
standing behind every surviving `AWAY-GOLDEN` reading (`R4.r10v173.txt`).

On **SeqDriver / MiniAmiq**, golden's def listing carries **ten** calls at one
span each **twice**, binding one copy to the def twin and one to the elaborated
twin: `uvm_re_match 403:11`, `uvm_glob_to_re 402:7`, `uvm_hdl_force 88:10`,
`uvm_hdl_release_and_read`, `uvm_instance_scope`, `uvm_oneway_hash`,
`uvm_report 168:4`, and the three `uvm_dpi_get_{next_arg,tool_name,tool_version}_c`.
Pristine put both copies on the elaborated twin; patched puts both on the def
twin. **Each binary therefore holds exactly one of golden's two buckets**, and
every one of those ten names appears in the *same* run's TO-GOLDEN list as
`PKGDEF->PKGDEF`: a relabelling, not a loss. `EvalFuncNamed`'s
`simple_minus 11:22` is the same shape at minimum size, and my `w173_t_imports`
arm reproduces it independently on `draught 13:9`.

The judge agrees it is a wash: SeqDriver 33 → 33 and MiniAmiq 40 → 40 with
**byte-identical head logs**, and across 158 boundary arms the official cmp
**grew on none**.

**R4 restated for the queue:** *which copy of a twice-listed def-listing call
takes the elaborated twin.* Decoding it is worth roughly 11 corpus cells plus
the two boundary arms; it is not a blocker for this landing.

## 6. RANKED RESIDUES (mine, after the pass's own R1–R5)

1. **R4 at corpus scale** (§5) — the one open sub-rule of this pass's own law,
   and the only source of a surviving `AWAY` cell anywhere I measured.
2. **R1 is the next mechanical step and it is already located.** The five
   class-qualified statics and the six `task_call` cells never reach the
   re-point loop because `ExprEmit.cpp:22158-22164` chose the twin at EMISSION.
   That site already carries the right idea — its comment reads *"Calls emitted
   INSIDE a package keep their own view's object"*, gated on `curPkgEmitSym` —
   so R1 is making `si.tf` listing-aware rather than inventing a new rule.
3. **R3 (listing copy count) now dominates the multiset censuses.** Our def
   listing carries a body twice where golden carries it once on `w173_s_shadow`,
   `w173_w_orders`, `w173_t_imports` and arm A's elab view. It predates this
   pass and this pass neither creates nor removes one, but it is why 11 of 13
   boundary rows need a bucket-membership rescoring to read clean.
4. **`Tnoc` segfaults (`rc=-11`) on both binaries**, recorded as `SLANG_REJECT`
   in the committed baseline. Out of this pass's scope; worth a row of its own
   in the queue, since RESUME §9 warns exactly this class hides behind a
   `SLANG_REJECT` label.

## 7. HOW TO REPRODUCE THIS VERIFICATION

```bash
git worktree add /tmp/wt_v173pris d53fbaad          # pristine
git worktree add /tmp/wt_v173     d53fbaad          # + git apply -3 the patch
#   NEVER pipe `git apply` into `head`: SIGPIPE kills it mid-write and it
#   applies NOTHING while printing "Applied ... cleanly" (it cost a build here).
for w in /tmp/wt_v173pris /tmp/wt_v173; do
  cmake -S $w -B $w/build -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PREFIX_PATH=$HOME/.local \
        -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++
  cmake --build $w/build -j 2
done
cp /tmp/wt_v173pris/build/slang-uhdm /tmp/v173_bin/pris.bin
cp /tmp/wt_v173/build/slang-uhdm     /tmp/v173_bin/pat.bin
chmod 555 /tmp/v173_bin/*.bin                       # freeze BEFORE any sweep

for f in ct173bind ct173cen ct173own ct173seed ct173who; do
  g++ -O2 -std=c++17 ../r10uvm173repro/$f.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/v173_scratch/$f
done

# the arms (both views, both binaries, fresh Surelog golden, every rc recorded)
CT173BIND=/tmp/v173_scratch/ct173bind \
  bash ../r10uvm173repro/grid173.sh w173_p_collide.sv \
       /tmp/v173_bin/pris.bin /tmp/v173_bin/pat.bin /tmp/v173_grid/w173_p_collide
python3 ../r10uvm173repro/score173.py /tmp/v173_grid/w173_p_collide \
       --only PKGDEF --nospan --setmode --list

# the boundary and the verdict on every arm it moves
PRIS=/tmp/v173_bin/pris.bin PATCHED=/tmp/v173_bin/pat.bin \
  bash ../r10uvm173repro/bound173.sh <copy of tools/probe> /tmp/v173_bnd
PRIS=... PATCHED=... bash ../r10uvm173repro/armjudge173.sh \
  /tmp/v173_bnd/MOVERS <copy of tools/probe> /tmp/v173_aj
```

Evidence: `GATES.r10v173.txt` (binaries, histograms, cmds.txt audit, ct8rows,
canaries, protected DBs, byteverify + the prediction, rowheads + head-log byte
comparison), `GRID.r10v173.txt` (all twelve arms), `BOUNDARY.r10v173.txt`
(4817 arms, 158 movers, every verdict, the 13 rescored),
`HEAD.r10v173.txt` (old head, pairing prover, typespec refutation, the law's
counts, EvalFunc's witness, the new head), `R4.r10v173.txt`.
