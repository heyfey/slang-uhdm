# r10v181 — ADVERSARIAL VERIFICATION of r10uvm181

**VERDICT: ACCEPT.** `/tmp/r10uvm181.patch` applies clean on a fresh
`e2190dd4`, its surface is `src/TaskFuncEmit.cpp` + `tools/probe/r10uvm181repro/`
only, and every headline number in the implementer's report reproduces on
binaries this verifier built itself — **including both binary md5s**.

Eight new arms were built against golden on axes the implementer's four never
enter (method-call PREFIX, `hier_path` struct members with an EMPTY map, block
shadowing, two clone packages, an explicit-import package, a module, three
instances, an EMPTYTF clone body with no `foreach` at all, and the use-site
axis). **AWAY = 0 and REGRESSION-CELLS = 0 in all eight.** One identity-level
divergence was found by an instrument built for it and is recorded as R-V1: it
is invisible to the judge (`uhdm-cmp` calls the arm that isolates it EQUAL on
the patched binary and NOT-EQUAL on the pristine one) and it does not occur in
the corpus at all.

---

## 1. BIT-FOR-BIT REPRODUCTION

| claim | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `0ce904c202e59398919f9f5e423a5167` | **same** |
| patched binary md5 | `571c08c5990c3654d23a2f8b0c3bea44` | **same** |
| SeqDriver `default`/`testflags` cmp lines | 29 → 13, 1 head | **29 → 13, 1 head** |
| the new head file | `head_pat_SeqDriver.default.cmp` | **byte-identical** |
| the old head file | `head_pris_SeqDriver.default.cmp` | **byte-identical** |
| SeqDriver census MISS/EXTRA/BINDWRONG | 493/61/574 → 373/61/574 | **same** |
| SeqDriver `EMPTYTF\|LOOPVAR` / `EMPTYTF\|OTHER` MISS | 63→23 / 80→0 | **same** |
| MiniAmiq census MISS/EXTRA/BINDWRONG | 512/76/136 → 392/76/136 | **same** |
| arm scores TOGOLD | 21 / 19 / 6 / 4 | **21 / 19 / 6 / 4**, AWAY=0 |
| arm A / B occurrences right | 831→877 / 594→632 | **same** |
| mover prediction | 9 candidates, `loopvar>0` = MiniAmiq×2 + SeqDriver×2 | **same, name for name** |
| per-mover order-blind dump diff | 240 added, 0 removed | **240 added, 0 removed** ×4 |

Every other named row's head is **byte-identical** between the two binaries:
`SimpleUVM`, `Scoreboard`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1`, `Rggen`,
in both modes. Only `SeqDriver` moved.

### The one number that differs: **5 movers, not 4**

`byteverify SELFCHECK=1` over this verifier's own pristine and patched surelog
workdirs reports **5 / 956**, not 4. The fifth is
`./default/Scoreboard-59431470/slang.uhdm`, and it is the documented COIN
(RESUME.md §9: svunit_pkg `vpiTaskFunc` list ORDER flip, ~50/50 per
invocation). Attributed the only admissible way — a path-normalised,
**order-blind** (sorted) `uhdm-dump` diff:

| database | order-blind ADDED | REMOVED |
|---|---|---|
| `default/Scoreboard-59431470` | **0** | **0** |
| `default/SeqDriver-32af76aa` | 240 | 0 |
| `default/MiniAmiq-544c7f61` | 240 | 0 |
| `testflags/SeqDriver-32af76aa` | 240 | 0 |
| `testflags/MiniAmiq-544c7f61` | 240 | 0 |

Scoreboard's dump is order-blind IDENTICAL, so its bytes moved and its content
did not — the coin, not this law. Its head file is byte-identical too. It was
also inside the implementer's *predicted* set (`loopvar=0 blockvar=33`), so no
mover of either run is unpredicted.

## 2. THE GATES, RE-RUN ON THIS VERIFIER'S OWN BINARIES

Two fresh worktrees at `e2190dd4`, both configured and built `-j 2`, both
frozen `chmod 555` before any sweep, `SLANG_UHDM` exported explicitly per
binary, and **every** `cmds.txt` audited by binary PATH.

1. **Build.** 0 errors both; md5s above; `Built target slang_uhdm` both.
2. **Goldens.** pristine 23 PASS / 0 FAIL; patched 23 PASS / 0 FAIL;
   `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (the harness really reads the
   binary it is told to).
3. **uhdm2rtlil.** 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in BOTH
   modes on BOTH binaries. `ct8rows` **0 differing rows** patched-vs-committed
   `results/gate_uhdm2rtlil.csv`, patched-vs-this-verifier's-pristine
   (testflags), and patched-vs-pristine (default). `cmds.txt` audit: 1458
   references, all `/tmp/v181_pat.bin` (patched) or `/tmp/v181_pris.bin`
   (pristine), **zero** to the main-tree binary.
4. **surelog `--mode both`.** 794 tests × 2 modes = 1588 rows, identical status
   histograms. `ct8rows` **0 differing rows over 1588** in all three
   comparisons (patched vs committed `results/golden_surelog.csv`, patched vs
   this verifier's pristine, pristine vs committed). **NO ROW CONVERTED** —
   `CMP_NOTEQUAL` stays 10 (default) + 9 (testflags). `results/*.csv` read
   only. `cmds.txt` audit: 1573 files, 1523 binary references, all frozen.
5. **byteverify SELFCHECK=1.** surelog **5 / 956** (four real + the Scoreboard
   coin, table above), uhdm2rtlil **0 / 1358**, `PATH_SETS_IDENTICAL` on both,
   SELFCHECK flagging 955/956 and 1357/1358 — the instrument can see.
6. **Canaries.** `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); both
   `ctcan2` PASS; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29
   UNCOVERED=0 FENCE-BREACH=0**. Protected databases, md5 pristine vs patched:
   `InterfaceModPort` `59a365f3ce2c` SAME, `BlackParrotComplex` SAME (both
   modes), `YosysOldOr` `d68e0796d62c` SAME, **`SVSwitch` `4842211c4030`**,
   **`YosysVerx` `6ccda350c24a`**.
7. **Fence.** The four slang-fenced names appear **0** times in the patch
   (excluding `canaudit.sh`, which names them to audit them) and are never
   dispatched by any driver here.
8. **Collateral.** No `results/*.csv` edit, no stray file, no hard-coded
   other-pass path, no `rm -rf` on shared scratch (`bound181.sh`'s
   `rm -rf "$WD"` targets `${BWD:-/tmp/r10uvm181_bound}`, its own).

## 3. THE EIGHT ADVERSARIAL ARMS

Each built as golden (Surelog, `def` and `elab`) plus BOTH frozen binaries, and
scored three-way with the implementer's `score181.py`. Names are unlike each
other, unlike the implementer's and unlike the corpus's, so an arm that agrees
agrees for a reason rather than by construction.

| arm | axis | verdict |
|---|---|---|
| `v181_a_use.sv` | THE USE SITE: rvalue, select index, index of a BLOCK-LOCAL array, argument by value, argument bound to an **output** formal, `case` selector, concat/replication, a `for` header, `$display`/`$signed`, ternary condition — in an EMPTYTF body, a HASLOCALS twin and a TASK | TOGOLD=13 **AWAY=0 MOVED-WRONG=0 REGRESSION-CELLS=0**, right 838→864 |
| `v181_b_prefix.sv` | THE PREFIX and HIER_PATH surface: `method_func_call` prefix that is a block-local handle / a class property / a package handle / `this`; struct member on a package-scope type vs a CLASS-scope type; a 3-deep nested path; an array-of-struct base indexed by the loop variable | TOGOLD=16 **AWAY=0 MOVED-WRONG=0 REGRESSION-CELLS=0**, right 1166→1212 |
| `v181_c_homes.sv` | TWO wildcard clones of one home, an EXPLICIT-import package, a MODULE that wildcard-imports, ×3 instances; 1-D/2-D/3-D with skipped slots; a NESTED foreach with DISTINCT names | TOGOLD=30 **AWAY=0 MOVED-WRONG=0 REGRESSION-CELLS=0**, right 834→894 |
| `v181_e_idxbase.sv` | the minimal `arr[i].member` cell alone | pristine **29 cmp lines / 1 head**, patched **0 lines / CMP_EQUAL** |
| `v181_f_mixed.sv` | a call ARGUMENT and an index BASE naming the same loop variable in one body | pristine **29 lines / 1 head**, patched **0 lines / CMP_EQUAL** |
| `v181_g_scopes.sv` | THE CLIMB's own axes: sibling and nested block SHADOWING of one name three times over, a sibling's name reached from the other block, the foreach ARRAY being a block local, a named begin, a FORK body, a `for` variable | TOGOLD=8 **AWAY=0 MOVED-WRONG=0 REGRESSION-CELLS=0**, right 696→714 |
| `v181_h_nofe.sv` | an EMPTYTF clone body with **no `foreach` at all** — law pkgCloneMember10 alone, over an EMPTY map | TOGOLD=6 **AWAY=0 MOVED-WRONG=0 STILL-WRONG=0**, right 705→723, every face agrees with golden |
| the implementer's four | re-built and re-scored here | TOGOLD 21/19/6/4, **AWAY=0**, REGRESSION-CELLS=0 |

Three results are worth naming individually.

**The HOME/CLONE boundary holds and the module does not move.** In
`v181_c_homes.sv` exactly **120 census rows differ** between the two binaries
and every one of them is in `caravel_impone` or `caravel_imptwo` — 60 each, the
same 60 faces in both clones. `caravel_home` (the HOME listing),
`caravel_impexp` (an `import home::name;` explicit import) and
`MOD:caravel_mod` (a module that wildcard-imports, instantiated three times)
are **byte-identical between the two binaries**. Instance count is irrelevant
and an explicit import is not a clone.

**Shadowing comes out exactly right.** `v181_g_scopes.sv` declares `scarp`
four times over — once in the foreach's block and once in each of three
sibling `begin : ravelin` / `: demilune` / `: hornwork` blocks. Golden binds
`scarp@31:7`→`@29:11`, `@34:9`/`@35:25`→`@33:13`, `@39:24`→`@29:11` (demilune
has no `scarp` of its own) and `@48:9`/`@49:25`→`@47:13`; the patched binary
reproduces all six cell for cell, and so did the pristine one (those cells bind
by ordinary emission, not by the climb). What DOES move is the block-local
array as the foreach's ARRAY (`ref_var:glacis` and `bit_select:glacis` →
`array_var:glacis@30:11`) and the nested loop variable `embrasure` — both to
golden.

**The negatives all hold.** In `v181_b_prefix.sv`'s clone, golden leaves BARE —
and both binaries leave BARE — the class-property prefix `rerebrace_prop`, the
package-handle prefix `baldric_pkghandle`, the CLASS-scope struct member
`besagew`, the class property of struct type `rerebrace_pkgtyped`, the
array-of-struct base `rerebrace_structarr`, and the middle element `poleyn` of
a 3-deep path. What moves is what golden binds: a block-local class handle as a
call PREFIX, a block-local struct variable and its PACKAGE-scope member.

## 4. THE SHARED-vs-MINTED QUESTION, SETTLED BY IDENTITY

`ct181grid.cpp` prints a bind target as `kind:name@line:col`, which cannot tell
the law cloneLoopVarShared37 object from a second object minted at the same
position with the same kind and name — and the pass's central claim is about
exactly that identity. `ctv181id.cpp` (this directory) labels every body
reference RELATIVE to its loop's listing entry:

* `SHARED` — vpiActual **is** the listing `ref_var`'s own vpiActual, the shared object;
* `LISTING-REF` — vpiActual is the listing `ref_var` itself, one hop short;
* `OTHER:<face>` — a third object;
* `BARE`.

DEF view, three arms, golden vs pristine vs patched:

| arm | golden | pristine | patched |
|---|---|---|---|
| `v181_a_use` | SHARED=44 BARE=22 | SHARED=20 BARE=49 | **SHARED=44** BARE=25 |
| `v181_b_prefix` | SHARED=14 OTHER=6 BARE=10 | SHARED=6 OTHER=2 BARE=25 | **SHARED=14 OTHER=6** BARE=13 |
| `v181_c_homes` | SHARED=80 BARE=19 | SHARED=16 BARE=95 | SHARED=76 BARE=35 |

The patched binary binds the **shared object**, not a minted twin, and reaches
golden's own SHARED count exactly in two of the three arms. `OTHER` never grows
where golden has none — nothing is being pointed at a manufactured object.

On the corpus (`SeqDriver`/`default`, golden vs both binaries, multiset join
per cell): occurrences right **1793 → 1833**, **REGRESSION-CELLS = 0**,
GAIN-CELLS = 20. `LISTING-REF` does not occur anywhere in that database, in
golden or in either binary.

## 5. THE WIDE BOUNDARY

`bound181.sh` (the implementer's, run with this verifier's own `PRI`/`PAT`/
`ROOT`/`BWD`) over a COPY of the whole of `tools/probe` **including this
verifier's eight new arms**: every `.sv` and `.v`, both binaries, DEF and ELAB,
fd-3 list with children `</dev/null`, recursive into subdirectory arms,
PROCESSED asserted against LISTED.

```
LISTED=4972  FENCED_SKIPPED=0  PROCESSED=4972  PROCESSED-ASSERT-OK
MOVED=17     NO_OUTPUT_PAIRS=380
```

Seventeen: the implementer's ten, plus seven views of this directory's own arms.
(`v181_g_scopes.sv` and `v181_h_nofe.sv` were written after the ROOT snapshot
and swept separately — `LISTED=2 PROCESSED=2 MOVED=4`.) The extra five files
over the implementer's 4967 are this directory's arms.
Every moved arm outside this pass's own is one the implementer already rebuilt
against golden and scored (`r10buvm19repro/grid19.sv` TOGOLD=18,
`r10uvm21repro/t32d/t.sv` TOGOLD=10, `r10v171repro/v171_b_faces.sv` TOGOLD=9,
`r10vbuvm19repro/vg19c.sv` TOGOLD=4, all AWAY=0). No arm named by any protected
boundary moved: the § `hpTrailSelIdxDecompiled89` / `rendersAsItself89` /
`selGroup89` cells, buvm14's `builtinRecvMultiDimStepIsBitSelectChain14`, the
uvm84/85 `this.`/`super.` arms, the uvm77-79 hier_path joint arms, the
uvm82-91 / buvm3-15 / sd8-12 arms, and the § `cloneLoopVarShared37`, uvm178 and
uvm180 arms are all inside the sweep and all still.

Both binaries segfault on the SAME arms (the driver counts those as
`NO_OUTPUT_PAIRS` and would print `ASYMMETRIC_OUTPUT` — a mover — if only one
of them did; none appeared).

**A dump-based boundary OVER-reports this law, and the line count must not be
read as damage.** `v181_h_nofe.sv/elab` is the worked example: the patched dump
is **234 lines SHORTER** (9488 → 9254), which reads like loss. It is not.
`uhdm-dump` is a tree walk; once a `vpiActual` edge is filled the walker reaches
an already-visited node and prints the short form instead of re-expanding the
subtree. Counting OBJECTS instead of dump lines settles it: the two databases
hold **TOTAL=1546 objects each, equal kind for kind**. That equality holds on
**every arm** (`a_use` 1166/2055, `b_prefix` 1447/2515, `c_homes` 1343/2564,
`e_idxbase` 280/420, `f_mixed` 359/550, `g_scopes` 1004/1747, `h_nofe`
1546/1546, def/elab) and on **every corpus mover** (`SeqDriver` 299429 and
299441, `MiniAmiq` 310097, `Scoreboard` 183926). This law fills edges. It mints
nothing and it drops nothing.

## 6. RESIDUES FOUND BY THIS VERIFICATION

* **R-V1 — the ELAB `arr[i].member` index base binds one hop too far.**
  `ctv181id` / `ctv181graph` on `v181_f_mixed.sv`: in the elaborated database
  Surelog emits two shapes of the clone body. In one of them golden binds a
  call ARGUMENT occurrence of the loop variable to the SHARED object but the
  INDEX-BASE occurrence (`petronel_structarr[wickyard].matchcord`) to the
  loop's LISTING `ref_var`; the patched binary binds all of them to the shared
  object, where the pristine binary happened to match golden on that one
  occurrence (having left the other two BARE). `score181.py` cannot see it —
  the listing `ref_var` and the shared object print the same
  `ref_var:wickyard@26:27` face — which is why the identity instrument exists.
  **It is not judge-visible and it is not a corpus cell.** `uhdm-cmp` on
  `v181_f_mixed.sv` and on `v181_e_idxbase.sv`: pristine **29 lines / 1 head
  NOT-EQUAL**, patched **0 lines / EQUAL**, in BOTH views. The DEF view of the
  same file has golden binding ALL occurrences to the shared object, which the
  patched binary matches exactly. `LISTING-REF` does not occur in the corpus
  (§ 4). Whoever takes the `ref_var::Compare`-reads-`Actual_group` chain should
  start here.

* **R-V2 — `$bits(<foreach loop variable>)` SEGFAULTS Surelog's UHDM
  elaborator** (`surelog 1.86`, rc=139, no `surelog.uhdm` written), so that one
  use-site face has no golden and was replaced by `$display`/`$signed` in
  `v181_a_use.sv`. Bisected to that construct alone: `partsel`, `for`-header,
  `case` selector and output-formal variants of the same file all return rc=0.
  A golden-side limitation, recorded so the next arm author does not spend the
  bisect again.

* **R-V3 — Surelog reports 7 `[ERR:UH0725] Unresolved hierarchical reference`
  on `v181_b_prefix.sv` in the ELAB view** (rc=4) for
  `baldric_pkgnest.poleyn.greave`, `rerebrace_prop.spaulder` and
  `rerebrace_pkgtyped.cuisse`. The database is still written and the arm still
  scores, but the golden for those three faces is a degraded golden; the DEF
  view is clean (rc=0) and carries the same faces.

* **The implementer's R1 (23 remaining `EMPTYTF|LOOPVAR` misses paired with 23
  `ONLY-GOLDEN` keys), R2 (the nested-foreach shadowing cell), R3 (39
  `EMPTYTF|OTHER` `BINDWRONG`) and R4 (the refuted typespec framing) all
  reproduce** as stated. R2's `MOVED-WRONG=1` in arm B is a never-right cell:
  0 occurrences agreed with golden before and 0 after, `REGRESSION-CELLS=0`.

## 7. REPRODUCE

```bash
# two worktrees at e2190dd4, the patch applied to one; build both -j 2, freeze
git worktree add /tmp/wt_v181 e2190dd4 && git worktree add /tmp/wt_v181pris e2190dd4
(cd /tmp/wt_v181 && git apply -3 /tmp/r10uvm181.patch)
for w in /tmp/wt_v181 /tmp/wt_v181pris; do
  cmake -S $w -B $w/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local
  cmake --build $w/build -j 2; md5sum $w/build/slang-uhdm
done
cp /tmp/wt_v181pris/build/slang-uhdm /tmp/v181_pris.bin
cp /tmp/wt_v181/build/slang-uhdm     /tmp/v181_pat.bin
chmod 555 /tmp/v181_pris.bin /tmp/v181_pat.bin

# the verifier's probes
for p in ctv181id ctv181graph; do
  g++ -O2 -std=c++17 tools/probe/r10v181repro/$p.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/v181_$p
done

# the eight arms (grid181.sh + score181.py are the implementer's instruments)
for a in a_use b_prefix c_homes e_idxbase f_mixed g_scopes h_nofe; do
  bash tools/probe/r10uvm181repro/grid181.sh tools/probe/r10v181repro/v181_$a.sv \
       /tmp/v181_pris.bin /tmp/v181_pat.bin /tmp/v181_g/$a /tmp/v181_ct181grid
  python3 tools/probe/r10uvm181repro/score181.py /tmp/v181_g/$a/cen.{g,a,b}.txt $a --quiet
done

# the identity question
/tmp/v181_ctv181id  <db.uhdm> <tag>
/tmp/v181_ctv181graph <db.uhdm> <tag> <substring-of-subroutine-name>

# the wide boundary, over a copy of tools/probe that includes these arms
cp -r tools/probe /tmp/v181_boundroot
PRI=/tmp/v181_pris.bin PAT=/tmp/v181_pat.bin ROOT=/tmp/v181_boundroot \
  BWD=/tmp/v181_bound bash tools/probe/r10uvm181repro/bound181.sh
```
