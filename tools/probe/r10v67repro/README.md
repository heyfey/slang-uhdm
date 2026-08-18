# r10v67 — ADVERSARIAL VERIFICATION of r10earl67 (§ genLpBitSelIdxOneHopFold67)

**VERDICT: ACCEPT.**  No production change was needed; this directory is
EVIDENCE ONLY.  Every headline number in the implementer's report was
reproduced BIT-FOR-BIT from independently built binaries, and the law survived
a five-arm break-it grid plus a recursive/per-directory boundary built from a
COPY of `tools/probe` with no path filter.

Fresh worktrees at `502642d`; both binaries built here, frozen `555`:

| binary | md5 |
|---|---|
| pristine `502642d` | `560a8eb9f2b4afcb5ea7f4e48a732169` |
| patched (`/tmp/r10earl67.patch`) | `ddf27fe553b2aeb4852d73f8de32abba` |

Both md5s are **identical to the implementer's**, so the build is
path-independent and every downstream number below is on the same bytes.

---

## 1. Reproduced bit-for-bit

* Earlgrey heads **46 -> 32**, ONE head per run, BOTH modes.  The two BEFORE
  cmp logs are byte-identical (`d0da4ae6b027`), the two AFTER logs are
  byte-identical (`710148f51aa2`), and **all four diff to ZERO against the
  committed `HEAD_R0_*.cmp`**.
* Whole-design census (`tscen67` + `nospan67` + `score67`, direct `.uhdm`
  reader): **1,995 TO-GOLDEN / 0 AWAY-GOLDEN / 0 MOVED-WRONG** in BOTH modes,
  and the pristine->patched changed-cell count is exactly **1,995** per mode —
  those cells are the ONLY cells that moved.
* Calibration golden-vs-golden **0 differing / 162,259** (default) and
  **0 / 160,030** (testflags).
* Superfamily `G=constant O=ref_obj`: **2,222 -> 227** (default),
  **2,396 -> 401** (testflags).
* Gates: goldens 23/0 on BOTH binaries + `/bin/false` 0/23; u2r 679/50/2 both
  modes both binaries; `ct8rows` u2r x3 PASS (committed baseline, own pristine
  tf, own pristine def); `byteverify SELFCHECK=1` u2r **MOVERS 0/1358**;
  surelog 1588 rows, status histogram IDENTICAL between binaries;
  `ct8rows` surelog x2 PASS (status AND dump); canaries 52/8 changed=0;
  ctcan2 PASS/PASS; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0; protected
  DBs SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`; rowheads: ONLY
  Earlgrey moved (46->32), SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 17,
  BuildUVMPkg 29, Rggen 64 unchanged.  `cmds.txt` audited file-by-file:
  1458 u2r + 1523 surelog slang lines per binary, every one the frozen
  `/tmp/v67_{pristine,patched}.bin`, and **zero** references to any other
  `slang-uhdm` path (the golden cache aside).  `results/*.csv` untouched.
* No row converted, no row unmasked; 0 differing rows on BOTH corpora.

## 2. `byteverify` surelog: 3/956 — and the third one is NOT the implementer's

MOVERS were `Earlgrey_0_1` default + testflags (predicted) and
**`SeqDriver`/testflags** — where the implementer measured `Scoreboard`/default.
That divergence is itself the proof that the third mover is the documented
COIN and not the law:

* the patched-vs-pristine dump diff on `SeqDriver`/testflags is **40 lines
  unsorted, ZERO order-blind**, and the lines are a `bit_typespec` ordering
  flip between `uvm_reg_addr_t` (uvm_reg_model.svh:73) and `uvm_reg_data_t`
  (:59) inside `uvm_pkg` — a construct this law cannot reach;
* re-running the sweep's exact command **6x with the patched binary and 6x
  with the pristine binary** gives the SAME hash both times,
  `7c1d08fe44b8b6428d2b257a7460852e`, which is the PRISTINE sweep's hash.  The
  patched sweep's `3bd23283ed02` was a flip under `--jobs 2` load.

So the surelog byteverify signal is: **Earlgrey x2, predicted by name; plus one
parallel-parse coin, exonerated by re-measurement.**

## 3. Breaking the law — five arms, both views, scored against golden

`v1_shapes67v.sv` declared type x initializer spelling; `v2_pos67v.sv` read
position x carrier; `v3_homes67v.sv` the home grid (gen-case, unnamed block,
interface gen scope, 2 instances x 3 unrollings, always_comb); `v4_calls67v.sv`
the call-argument fence at every mixed nesting; `v5_edge67v.sv` the refusal
edges (shadowing, real/string siblings, unnamed declaring block).
Full table in `SCORES_v67.txt`.  **AWAY-GOLDEN = 0 in every arm and every
view** — no cell that was RIGHT before is WRONG after, anywhere.

### 3a. The fences HOLD

* **Call-argument fence.**  `v4` measured `USER(SYS(x))`, `SYS(USER(x))`,
  `SYS(SYS(x))`, `USER(USER(x))`, a DIRECT (unwrapped) user argument and a
  package-qualified call, each beside a distance-0 twin.  Only the two cells
  golden folds moved — `SYS(SYS(x))` and the reads outside any call.  Every
  user-call spelling stayed on its pristine (correct) arm, and every distance-0
  twin was untouched.  `callArgDepth - sysCallArgDepth22 == 0` is the right
  spelling; a plain `callArgDepth == 0` would have broken `SYS(SYS(x))`.
* **`inGenScopeCa67` fence.**  Zero `HC_*` (port High_conn) cells and zero
  DEF-section cells changed in ANY arm or view.
* **The one-hop predicate.**  `v5`'s SHADOWING cell (`localparam K` at
  distance 0 shadowing `localparam K` at distance 1) correctly REFUSES —
  `genLpUseFoldBound47`'s `it->second.ps != &sym` identity test catches it.
  (Golden itself is odd there: Surelog binds the OUTER `K`, slang the inner
  one, so golden holds `UINT:g+1` where we hold an unbound ref.  That is a
  PRE-EXISTING residue this pass neither creates nor touches — logged as V-R4.)
* Distance 0 / 2 / 3, genvars, module localparams, package parameters and
  child port parameters are unmoved everywhere.

### 3b. V-F1 — the ONE thing the pass's own arms do not see

`v1_shapes67v.sv` scores **14 MOVED-WRONG per view** (7 shapes x 2
unrollings).  They are NOT regressions — the pristine object at every one of
them is an unbound `ref_obj`, i.e. already wrong — but they refute the
report's "**0 MOVED-WRONG in every arm and every view**" as a statement about
the LAW's domain rather than about the shipped arms.

The fold is a COPY of the localparam's own `param_assign` Rhs constant.  That
copy is field-exact only when the initializer is an EXPRESSION or a BASELESS
literal.  For a SIZED or BASED literal initializer golden's index constant is a
RE-ENCODING, and the copy misses it — the very split
`§ genLpPortConnCopyableOnly11v` (r10vrgg11) already documented for the
port-actual site:

| initializer (declared type) | golden's index constant | patched copy | judge fields wrong |
|---|---|---|---|
| `8'h05`   (`int unsigned`)      | ct 5 `HEX:05` sz 32 dec `32'h05` | dec `8'h05`        | 1 of 4 |
| `4'b0111` (`int unsigned`)      | ct 3 `BIN:0111` **sz 4**         | sz 32              | 1 of 4 |
| `6'd6`    (`int unsigned`)      | ct 7 `INT:6` dec `6`             | ct 9 `UINT:6` dec `6'd6`   | 3 of 4 |
| `6'o10`   (`int unsigned`)      | ct 9 `UINT:8` dec `8`            | ct 4 `OCT:10` dec `6'o10`  | 3 of 4 |
| `64'd11`  (`longint unsigned`)  | ct 7 `INT:11` dec `11`           | ct 9 `UINT:11` dec `64'd11`| 3 of 4 |
| `8'd12`   (`byte`)              | ct 7 `INT:12` dec `12`           | ct 9 `UINT:12` dec `8'd12` | 3 of 4 |
| `16'sd13` (`shortint`)          | ct 7 `INT:13` dec `13`, ts `int_typespec` signed | ct 9 `UINT:13` dec `16'sd13`, ts `short_int_typespec` | 3 of 4 + ts |

Seven OTHER shapes fold field-exactly and are TO-GOLDEN: a module parameter, a
package parameter, a package function call, a local function call, a typedef'd
type, signed arithmetic, a `$clog2` initializer and a signed vector.

**Why this is not a blocker and was NOT fixed here.**  In 6 of the 7 shapes the
patched object is strictly CLOSER to golden than the pristine one (the object
KIND now matches and 1-3 of the 4 constant fields are right, against 0 for a
`ref_obj`), so refusing the fold for these encodings — the earl11-style gate —
would move the corpus AWAY from golden, not towards it.  Earlgrey carries none
of these shapes (all 1,995 cells are genvar-expression initializers), no
corpus row moves, and the correct fix is the re-encoding law itself, which is
a pass of its own.  Ranked V-R1.

## 4. Boundary — recursive AND per-directory, from a COPY of `tools/probe`

Built from `/tmp/v67_probe` (a copy), **no path filter, `.sv` AND `.v`**, list
on fd 3, children `</dev/null`, `PROCESSED` asserted, rc recorded per cell.

* WIDE: **3,056 files listed (.sv AND .v), PROCESSED == LISTED**, 16 differing —
  this pass's 3 arms x 2 views + `r10earl47repro/a2_earl47`,
  `r10earl56repro/a1,a2,a4`, `r10earl58repro/a1_earl58`, each x 2 views.
* PER-DIRECTORY: **1,387 dirs, PROCESSED == LISTED**, 12 differing —
  `r10earl47/56/58/67repro` x 2 views (the same files) and
  `r10uvm75repro` / `r10uvm76repro` x 2 views.
* Every mover was **SCORED against a rebuilt Surelog golden**, field-by-field,
  with a NO-SPAN judge-fields payload (`SCORES_v67.txt`):
  `a2_earl47` 6 TO-GOLDEN, `a1/a2/a4_earl56` 1 each, `a1_earl58` 8 + 2 —
  **0 AWAY-GOLDEN, 0 MOVED-WRONG** once the key artefact below is normalised.
* `a1_earl58`'s 2 "MOVED-WRONG" are a KEY artefact, reproduced and named
  independently: the cells live in an UNNAMED generate block that slang numbers
  `genblk2` and Surelog numbers `genblk7`, so the positional key does not join
  and golden reads `<none>`.  Golden's object at ITS key is
  `constant ct=9 sz=32 UINT:4 dec=4 int_typespec` — **byte-for-byte what the
  patched binary now emits**.  10 TO-GOLDEN / 0 AWAY / 0 MOVED-WRONG.
* `r10uvm75/76repro` are the documented `vpiTaskFunc` ORDER COIN: unsorted diff
  14-20 lines, **order-blind diff ZERO** on all four (dir, view) cells.
* rc=139 signals appear on BOTH binaries, **paired one-for-one** (wide and
  per-directory alike) — pre-existing, none introduced.

## 5. Ranked residues (for the next pass)

* **V-R1 — the copy's ENCODING (this pass's own domain).**  §3b.  The fold
  copies the `param_assign` Rhs verbatim; golden re-encodes SIZED and OCTAL
  literals and re-decompiles HEX to the declared width.  The corpus-visible
  form of this is `§ genLpPortConnValue11` / `§ genLpPortConnCopyableOnly11v`;
  a single re-encoding helper would serve the port actual, the param_assign
  and now the bit-select index.
* **V-R2 — the positions the call site still does not reach**, all measured on
  golden in `v2_pos67v.sv` (golden folds, we keep an unbound ref):
  a NESTED index (`w[m[Ku]]`), a `var_select` element index (`mem[Ku][Kv]`),
  a `hier_path` element index (`u_s.s[Ku]` — this is the *shape* of the
  implementer's R1, 261 testflags cells), an `indexed_part_select` BASE that is
  itself a bit-select, and an operation operand in a ternary predicate.
* **V-R3 — the net-decl-assign gen CA.**  `emitGenScopes` builds `ndaCas`
  BEFORE the loop the guard wraps, so a `logic [15:0] x = w[Ku];` inside a gen
  scope is out of the law's reach by construction.  Measured: golden and we
  agree there today, so it is a REACH note, not a defect.
* **V-R4 — shadowed gen localparams.**  Surelog binds the OUTER declaration
  where slang binds the inner one (`v5_edge67v.sv` L19, 5 cells).  Pre-existing.
* **R0/R1 (the implementer's, confirmed from the AFTER log):**
  `prim_arbiter_tree.sv:114:20-114:42`, `cont_assign::Rhs`, golden reduces a
  bare GENVAR read to a location-less `constant UINT:0 sz 64 ct 9` with no
  typespec; 89 cells both modes.  Its testflags twin is the same mint inside a
  `hier_path` element index, 261 cells.  Together 350 of the 628 remaining
  superfamily cells.

## 6. Files

`v{1..5}_*67v.sv` — the five break-it arms.  `SCORES_v67.txt` — every arm and
every boundary mover scored 3-way.  `HEAD_v67_{BEFORE,AFTER}_{default,testflags}.cmp`
— the four cmp logs measured HERE (identical to the pass's).
`BOUNDARY_{wide,dir}_v67.{tally,diff,signal}`.
`vwide67v.sh` / `vdir67v.sh` — the boundaries as run (own stage dirs).
Scoring reuses the pass's `tscen67` / `cen67.sh` / `nospan67.sh` /
`score67.py` / `sfam67.py` / `runarm67.sh` — MEASUREMENT ONLY; the official
`uhdm-cmp` remained the sole judge for every acceptance claim above.
