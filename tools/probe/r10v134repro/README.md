# r10v134 — adversarial verification of r10uvm134
## § `foreachLoopListStopsAtFirstSelect134` + the verifier's clause
## § `loopListTruncationIsWrittenToo134v`

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduces bit-for-bit from a fresh `f08eee0` build. Four
pristine-RIGHT → patched-WRONG cell classes on legal SystemVerilog were found
by this verifier's grid, all outside the implementer's grid's coverage and all
corpus-invisible; they are fixed here, in one gated clause, and the fixed
binary is **byte-identical to the un-fixed one on all 956 surelog and 1358
uhdm2rtlil databases**.

---

## 1. Reproduction of the implementer's numbers (independent build)

Worktrees `/tmp/wt_v134` (patched) and `/tmp/wt_v134pris` (pristine), both at
`f08eee0`, configured and built `-j 2`, md5 taken separately, frozen `chmod 555`
at `/tmp/v134_bin/{pris,pat}.bin`.

| claim | implementer | verifier | verdict |
|---|---|---|---|
| pristine binary md5 | `583b10a735e405dcfaeb2f49695d6632` | same | REPRODUCED |
| patched binary md5 | `3f049592b1a740326413109b70367be1` | same | REPRODUCED |
| MiniAmiq head (both modes) | 80 → 56, 1 head | 80 → 56, 1 head | REPRODUCED |
| every other row's head | 17 / 64 / 64 / 60 / 150 / 0 unchanged | identical | REPRODUCED |
| goldens | 23 PASS 0 FAIL; `/bin/false` 23 FAIL | identical | REPRODUCED |
| u2r testflags + default | 679 / 50 / 2 each | identical | REPRODUCED |
| u2r `ct8rows` | 0 differing rows | 0 (vs committed baseline AND vs own pristine, both modes) | REPRODUCED |
| u2r `byteverify SELFCHECK=1` | MOVERS 0/1358 | 0/1358, selfcheck 1357/1358 | REPRODUCED |
| surelog `--mode both` histogram | 937/567/48/19/10/3/2/1/1 | identical, and identical to own pristine | REPRODUCED |
| surelog `ct8rows` | 0 differing rows over 1588 | 0 (vs committed baseline AND vs own pristine) | REPRODUCED |
| a-priori prediction (`pred134.sh`, 956 DBs) | exactly 9 named rows, 0 census failures | identical 9 names, 0 failures | REPRODUCED |
| `byteverify SELFCHECK=1` surelog | MOVERS 9/956, exactly the predicted names | identical | REPRODUCED |
| order-blind mover attribution | 74 / 408 / 74 / 142 / 74 differing lines | identical | REPRODUCED |
| canaries / ctcan2 / canaudit | ok=52/0, ok=8/0, PASS×2, PASS 29 names | identical, `UNCOVERED=0 FENCE-BREACH=0` | REPRODUCED |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three byte-identical | identical | REPRODUCED |
| `results/*.csv` | untouched | untouched (patch surface is `src/StmtEmit.cpp` + `RESUME.md` + the repro dir) | REPRODUCED |

`cmds.txt` audit by binary PATH, file by file: surelog sweep 1523 invocations
(1573 files; the rest are golden-cache-hit / SURELOG_FAIL rows with no slang
line), u2r sweep 1458 (1462 files, 4 of them SURELOG_FAIL / cache-hit-only) —
**one binary each, zero main-tree leaks** in all four sweeps. The
implementer's "2981 hits per sweep" is 1523 + 1458, i.e. the sum over both
sweeps, not a per-sweep figure.

### 1b. Independent corpus census (not the implementer's)

`ct134cen` over the golden cache DB, the pristine DB and the patched DB of all
**nine movers**, scored with `score134.py`'s multiset join
(`HOME|PATH|SPAN|NLV|LVNAMES`), 9365 foreach cells:

```
RIGHT->WRONG 0   ONLY-GOLDEN 0   ONLY-OURS 0   AWAY 0     in EVERY column of EVERY database
VKIND/VNAME/VFULL   WRONG->RIGHT  2 / 13 / 2 / 4 / 2  (default) + 2 / 13 / 4 / 2 (testflags)  = 44
LVKINDS/LVTS        WRONG->RIGHT  1 per database                                              =  9
VSPAN               WRONG->RIGHT 44, RIGHT->WRONG 0  (the pass converts spans, creates none)
```

which is exactly the implementer's "44 Variables cells + 9 loop-variable cells,
RIGHT→WRONG 0". Corpus-side the patch is clean.

---

## 2. What the adversarial grid found — four regressions

Six new arms (`v134_1kinds` … `v134_6mods`, 6 files, both views), covering
faces the implementer's five arms did not: associative arrays keyed by
string / int / enum / class handle; queues, dynamic, fixed 1-D and 2-D;
element members that are themselves assoc arrays, strings and 2-D arrays;
eight homes including a **package-level array variable**, a program and an
interface; 1–3 instances in one scope; seven body shapes; and — the three
shapes that broke — a **`::`-written array reference under a select**, a
**`super.` root**, and a **package-level class-handle array** under the
truncated loop list.

All four are cells where **pristine matched golden and the patched binary did
not**. All four are absent from the corpus (see §4), which is why the
implementer's gates were green.

### REG-A / REG-B — the package-level array's loop variable

`foreach (pkgtwigs[p7].wa[p8])` over a package-level `Twig2 pkgtwigs[4]`
(`v134_2homes.sv:24`, and `Mid3 pkgmids[$]` in `v134_3shapes.sv:66`):

| | Variable | loop variable |
|---|---|---|
| golden | `ref_var 'pkgtwigs'` + `array_typespec` | **`array_var` + `array_typespec`** |
| pristine | `hier_path 'pkgtwigs[p7].wa'` (wrong) | `array_var` + `array_typespec` (right) |
| patched | `ref_var 'pkgtwigs'` + `array_typespec` (right) | **`class_var` + `class_typespec`** (wrong) |

Cause: § `foreachPkgClassArrayVar25`'s gate is
`arrBase->kind == SyntaxKind::IdentifierName`, read off the **written** loop
list. The truncated reference *is* the bare name `pkgtwigs` — that law's exact
subject — but the written syntax is still a `ScopedName`, so the gate missed
and the loop variable fell through to the class-element drill. 2 cells in
`v134_2homes.elab`, 1 (def) + 2 (elab) in `v134_3shapes`.

### REG-C — the `::`-written array reference under a select

`foreach (this_type5::statnodes[w7].nq[w8])` (`v134_5inter.sv:30`), a class
static array written through a `this_type` typedef — the corpus's own
`this_type::m_typewide_sequences` spelling with an index select added:

| | VKIND | VNAME | VTS | VSPAN |
|---|---|---|---|---|
| golden | `class_var` | `this_type5::statnodes` | `unsupported_typespec` | 30:52-30:64 |
| pristine | `ref_obj` | `this_type5::statnodes` | NOTS | 30:52-30:64 |
| patched | `ref_var` | **`statnodes`** | `unsupported_typespec` | **30:52-30:61** |

**VpiName is read by `Compare`**, so this one is judge-visible: the patch traded
a right name for a right typespec. Cause: `foreachScopedArrayName33` reads the
`::` text off `arrBase` and refuses a node whose top separator is `.`. The same
three-cell pattern appears for a `pkg::`-written reference
(`zpk5::pkgnodes[w9].nf[wa]`). 3 def cells + 9 elab cells (three listings each).

### REG-D — a `super.`-rooted loop list

`foreach (super.bn[w3].nq[w4])` (`v134_5inter.sv:23`). Golden answers a
**nameless `logic_var`** for the plain `super.bplain[i]` and the selected
`super.bn[i].nq[j]` spelling alike — Surelog's implicit-class-handle strip does
not produce a name for a `super` root at all, so the truncation is not
observable there. Pristine emitted a `hier_path` with an empty `VpiName`
(matching golden's empty name); the patch emitted `ref_var 'bn'`, moving
`VpiName` off golden. Neither binary models the `logic_var`; the honest action
is to leave the shape exactly as pristine emitted it. 1 def cell + 3 elab cells.

### Not a regression — one `VTSNAME` cell in `v134_2homes.elab`

`score134.py` pairs a key's rows **by index**. At
`package(hpk2)/function(free_fn2)/foreach_stmt` golden holds 3 rows and we hold
4 (a pre-existing listing-count difference — the same key carries this arm's
`ONLY-GOLDEN=6 / ONLY-OURS=6`). As MULTISETS the patched `VTSNAME` bag
`{pkgtwigs, pkgtwigs, -}` matches golden's `{-, pkgtwigs, pkgtwigs}` exactly and
pristine's `{-, -, -}` does not; the printed `RIGHT->WRONG=2` is the index
pairing, not a move. Verified by counting the bags directly.

---

## 3. The fix — § `loopListTruncationIsWrittenToo134v`

`src/StmtEmit.cpp`, inside the same `ForeachLoop` arm, ~50 lines.

The implementer truncated the **AST** reference (`arrRef134`) but left the
**written syntax** (`arrBase`) spelling the whole `x[i].y`. Four gates below
read `arrBase`, so the two disagree. The clause truncates the written
reference by the same rule and hands it to the two gates that decide a KIND or
a NAME:

* walk the `ScopedName` **left spine**, find the leftmost segment carrying an
  index select, keep the prefix node that ENDS at it — always a real node,
  because `ScopedName` nests to the left (`a.b[i].c` is
  `SN(SN(a, b[i]), c)`, so the prefix `a.b[i]` is `SN(a, b[i])`);
* `arrTrunc134` records that the truncation fired, and every widened gate is
  conditioned on it, so an **untouched shape stays byte-identical to pristine
  by construction**;
* `foreachScopedArrayName33` is given the truncated node (REG-C);
* § `foreachPkgClassArrayVar25`'s bare-name gate also accepts
  `arrTrunc134 && arrBareTrunc134` — the truncation left ONE identifier
  (REG-A/B);
* a `super`-rooted loop list is excluded from the rewrite entirely (REG-D).

Deliberately NOT changed: the `nameSpan(arrBase->sourceRange().start(), …)`
call at the `ref_var` arm. For every truncated shape the truncated node's start
is the same token as the full node's start, so it is a no-op; leaving it alone
keeps the delta minimal.

### Fixed-binary results

md5 `22cb27b2103032395373717f9cba9c6c` (frozen `/tmp/v134_bin/pat2.bin`).

* Verifier grid, 6 arms × both views: **REG-A/B/C/D all gone.** `LVKINDS`/`LVTS`
  `RIGHT->WRONG` 3 → 0, `VNAME` 12 → 0, `VTSNAME` 4 → 0 (the one remaining
  printed cell is the index-pairing artifact of §2), `VSPAN` 8 → 0.
* Implementer's own grid (`arms134.sh`, 5 arms × both views, 259 cells/view):
  **`RIGHT->WRONG` 0, `ONLY-GOLDEN` 0, `ONLY-OURS` 0, `AWAY` 0**; 721
  column-conversions, 1277 already-right, 74 still-wrong.
* Corpus: goldens 23/0; u2r 679/50/2 both modes, `ct8rows` 0 rows, byteverify
  **0/1358**; surelog histogram identical to pristine, `ct8rows` 0 rows over
  1588, byteverify **9/956 — the same nine names and THE SAME NINE MD5s as the
  un-fixed patched binary**, so the fix is provably corpus-byte-invisible.
* Heads unchanged from the implementer's: MiniAmiq 56 both modes, SeqDriver 17,
  SimpleUVM 64, Scoreboard/default 64, BuildUVMPkg 60, Earlgrey 150, Rggen 0.
* Canaries ok=52/0 and ok=8/0, ctcan2 PASS ×2, canaudit PASS
  (`UNCOVERED=0 FENCE-BREACH=0`), all five byte pins hold.

---

## 4. Wide boundary gate

`bound134.sh` over the list `bound134v.sh` builds — every probe tree containing
a `foreach`, PLUS the whole of `r10uvm77-79 / 82-91 / 113 / 122 / 131`,
`r10buvm3-15 / 33 / 34`, `r10sd8-12` whether or not they write one:

```
LISTED=991 PROCESSED=991 MOVED=22 BREACH=0 RC-MISMATCH=0 NORUN=30   -> BOUNDARY PASS
```

The 22 moved views are the 11 grid arms (5 implementer + 6 verifier) × 2 views
and nothing else — **no foreign arm moved**, in particular none of buvm33's
`§ foreachScopedArrayWrittenClassVar33`, buvm34's
`§ foreachScopedArrayLoopVarIntFallback34`, uvm122's
`§ localBlockStmtSelBinds122`, uvm131's fork arms, or uvm84/85's `this.`/`super.`
cells. Positive control (`CTRL=1` over the five implementer arms): fires on all
10 views.

Corpus reach of the four regressions, measured on all 956 pristine surelog
databases (9414 foreach cells): `VKIND` is `ref_var` 8414 / `hier_path` 974 /
`class_var` 26 and **`ref_obj` 0** — REG-C's pristine signature does not occur;
all 26 `class_var` cells are `this_type::m_typewide_sequences` with **no**
index select (`VFULL` carrying a `[`: 0). No `super.`-rooted or package-level
truncated foreach exists either. All four are corpus-invisible, which is why
they cost nothing on the judge and why the fixed and un-fixed binaries emit
identical corpus bytes.

---

## 5. Reproducing

```bash
CEN=<ct134cen>                       # built from ../r10uvm134repro/ct134cen.cpp
SRC=$PWD PRI=<pristine> PAT=<patched> CEN=$CEN WD=/tmp/v134_arms \
  bash varms134v.sh                  # the 6 arms, both views, golden/pris/pat scored
bash bound134v.sh > /tmp/v134_list.txt
PRI=<pristine> PAT=<patched> CEN=$CEN FILES=/tmp/v134_list.txt \
  bash ../r10uvm134repro/bound134.sh
```

`ct134cen`, `score134.py`, `pred134.sh`, `bound134.sh`, `rowheads.sh`,
`ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh` and `canaudit.sh` are
the implementer's, re-run unmodified; the official `uhdm-cmp` remains the sole
acceptance judge and everything here is MEASUREMENT ONLY.

---

## 6. Residues, ranked

* **R0 — unchanged.** MiniAmiq ×2, 56 lines, `uvm_phase.svh:1740`
  `foreach (pred.m_predecessors[next_pred])`: golden's loop variable is
  `int_var` + a bare `int_typespec`, ours `class_var` + `class_typespec
  'uvm_phase'`; `swapForSpecifiedVar` feeds the hier_path to `decodeHierPath` as
  written and falls to the `:2550` `int_var` default — the same fallback
  § `foreachScopedArrayLoopVarIntFallback34` decoded for the `::` spelling.
  9 cells over the nine UVM databases and the only `LVKINDS` cell still wrong
  there. CONFIRMED independently by this verifier's corpus census.
* **R1 — `foreach (this.<a>.<b>[i]…)`** (implementer's R1, unchanged and still
  correct): after stripping `this.` two names remain, so golden builds
  `hier_path 'a.b'` where we answer § `classPropIterThisRefVar21`'s
  `ref_var 'b'`. 4 grid cells (`v134_3shapes` `l_thisdotidx` reproduces it),
  **0** corpus cells.
* **R2 — `super.`-rooted foreach is a NAMELESS `logic_var` in golden**, both
  spellings, and we emit a `ref_var` / `hier_path` in every view. Newly
  measured here (`v134_5inter` `d_super` / `d_superb`); pre-existing, 0 corpus
  cells, and the reason the fix excludes the shape rather than modelling it.
  A future pass wanting it must decode Surelog's `paImplicit_class_handle` arm
  for `super`.
* **R3 — the `::`-written reference under a select is still `ref_obj`-shaped in
  neither binary's favour on VKIND.** With the fix, golden's
  `class_var 'this_type5::statnodes'` + `unsupported_typespec` is now matched on
  NAME, TYPESPEC and SPAN; `VKIND` (`class_var`) is matched too. What remains
  wrong there is only the loop-variable arm's interaction, and it is
  corpus-invisible.
* **R4 — dump-only spans** (implementer's R2): our loop-list `hier_path` carries
  a span where golden's carries none, and our `this.`-rooted `ref_var` spans the
  name where golden spans the `this` token. Pre-existing; the pass converts 44
  `VSPAN` cells corpus-wide and creates **0**.
* **R5 — interface- and program-homed foreach loop variables**
  (§ `foreachHierPathAlwaysRes21`, implementer's R3): golden unresolved
  `ref_var`, ours resolved. Reproduced in `v134_2homes` and `v134_6mods`; wrong
  before and after.
