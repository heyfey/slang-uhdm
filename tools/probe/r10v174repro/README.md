# r10v174 — the ADVERSARIAL VERIFICATION of r10uvm174 § `pkgDefClassCloneNoBitsFold174`

**VERDICT: ACCEPT-WITH-FIX.** The law holds, every headline number reproduces
bit-for-bit from binaries the verifier built itself, and seven purpose-built
adversarial arms plus a 4854-file wide boundary find **AWAY-GOLDEN = 0**
everywhere. The one fix is a five-line **comment** in `src/ExprEmit.cpp` that
still said the shipped law was "DECODED BUT NOT SHIPPED … the next head (R0)";
it is rewritten in place, and the rebuilt binary is **byte-identical**
(`9b5f05dfd8e3b7688267182183b4c173`), so no measurement here is invalidated.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities.
slang was **NOT** patched; `results/*.csv` were **READ ONLY**; **no row was
converted**; `GOLDEN_DEFER` was never set. The four slang-fenced tests were
never dispatched and are not spelled in any file here.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table and
every script.

| | |
|---|---|
| BASE | `a0a33bb3` |
| worktrees | `/tmp/wt_v174` (patched), `/tmp/wt_v174pris` (pristine, later reused for the no-fence counterfactual) |
| pristine binary | md5 `9853d69d43a9cf87884b368be6f16c7f` — **matches the implementer's, built independently** |
| patched binary | md5 `9b5f05dfd8e3b7688267182183b4c173` — **matches the implementer's** |
| no-fence binary | md5 `8be4e7e67941f5587cac08379e6d5e34` — the counterfactual only, never a candidate |
| production surface | `src/ExprEmit.cpp` (+45/−0 gate, +0/−0 net on the comment rewrite) |

---

## 1. WHAT WAS REPRODUCED BIT-FOR-BIT

Both binaries were rebuilt from scratch in fresh worktrees and froze to
identical md5s, so the whole battery below is a re-derivation, not a re-read.

* goldens **23 PASS / 0 FAIL on both binaries**, `/bin/false` **0 PASS / 23 FAIL**;
* uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in both modes
  on both binaries; `ct8rows` **0 differing rows** against the committed
  baseline *and* against the verifier's own pristine control, status and dump;
* surelog **0 differing rows over 1588**, status histograms identical between
  the binaries; **no row converted**;
* `byteverify SELFCHECK=1` **9 / 956** and **0 / 1358**, selfcheck 955/956 and
  1357/1358;
* canaries `ok=52 changed=0` and `ok=8 changed=0`; `ctcan2` PASS on both
  corpora; `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* protected databases byte-identical, **`SVSwitch 4842211c4030`** and
  **`YosysVerx 6ccda350c24a`** both held;
* heads: `SimpleUVM ×2 40 → 52` on a **new object**, `Scoreboard/default 95`,
  `MiniAmiq ×2 40`, `SeqDriver ×2 33`, `BuildUVMPkg ×2 52`,
  `Earlgrey_0_1 31/122`, `Rggen` CMP_EQUAL; ONE `^LHS:` per run everywhere.

**The cmds.txt audit** (the silent-`SLANG_UHDM`-default trap) was run
file-by-file over all 6070 sweep `cmds.txt`: every one names the intended
frozen binary and **zero** name the main-tree binary.

| workdir | cmds.txt | binary named |
|---|---|---|
| slpris | 1573 | 1523 × `/tmp/v174_bin/pris.bin` |
| slpat | 1573 | 1523 × `/tmp/v174_bin/pat.bin` |
| u2rpris | 1462 | 1458 × `/tmp/v174_bin/pris.bin` |
| u2rpat | 1462 | 1458 × `/tmp/v174_bin/pat.bin` |

**The head object really changed.** The pristine head was
`sys_func_call($bits)@731:34` vs `constant UINT:8`; the patched head is
`ref_var` vs `enum_var` at `uvm_sequencer_base.svh:1389`, and the string
`731:34` appears **0 times** in the patched head log (6 times in the
pristine one). Golden's `enum_typespec` is at `332:40-332:56`, ours at
`359:1-367:26` — the implementer's R0, confirmed verbatim.

**Scoreboard/default, the coin, attributed order-blind.** Sorted
path-normalised `uhdm-dump` diff = **268 lines of 1 100 350**: 17 constants
out, 34 `sys_func_call` lines in (the dump prints each object twice), 17 typed
argument variables and their fields. **Zero `svunit_pkg` lines** — the coin did
not flip in this pair, and the byte move is the law and nothing else.

---

## 2. THE PREDICTION, MADE INDEPENDENTLY AND FROM THE OTHER SIDE

`vpredict174.sh` does not read the patched sweep at all. For every pristine
database it runs the census on **that database and its golden** and asks:
*does golden keep a type query at a PKGDEF-listing position whose home is an
out-of-body (`::`-named) class method, where we do not?* That names the CELLS,
not merely the windows, so it brackets the truth from the opposite side to the
implementer's constant-shaped scan of our own databases.

```
surelog    SCANNED=956  PREDICTED_MOVERS=9  CONST_IN_WINDOW_NOT_PREDICTED=2  SCANFAIL=0
uhdm2rtlil SCANNED=1358 PREDICTED_MOVERS=0  CONST_IN_WINDOW_NOT_PREDICTED=0  SCANFAIL=0
```

The nine named, with cell counts, **before** the mover set was looked at:
`BuildUVMPkg` 46 (default, testflags), `SimpleUVM` 17 ×2, `SeqDriver` 17 ×2,
`MiniAmiq` 17 ×2, `Scoreboard` 17 (default). The two rows that carry the window
but were predicted **not** to move are `ApbSlave` ×2 (25 of our constants in
the window, **0** cells golden keeps and we fold) — and they did not move.

`byteverify SELFCHECK=1` then realised **exactly those nine and no other**.
Prediction == reality, derived two different ways.

---

## 3. THE ARMS (`GRID.r10v174.txt`) — seven, none sharing a name with the implementer's

Each arm is compiled by **Surelog** and by **both frozen binaries** in **both
views**, every rc recorded, scratch keyed on the relative path, `uhdm-cmp` run
per view with both inputs existence-checked. **Non-zero rc: 0 on all seven.**
Scoring is by POSITION = (listing, home, name, line, col); listings are read
structurally and **never merged**.

| arm | what it varies | verdict |
|---|---|---|
| `v174_a_faces.sv` | 19 `$bits` argument faces (type keywords, package typedef, unpacked-array typedef, class-local typedef, own property, property of a package typedef, local, formal, class localparam, package localparam, package parameter, expression, real, time, static) × out-of-body method / out-of-body task / in-block twin / free package function | **TO-GOLDEN 11, AWAY-GOLDEN 0** (def); the DEF listing now equals golden |
| `v174_b_sysfns.sv` | 11 type queries (`$clog2 $size $high $low $left $right $increment $dimensions $unpacked_dimensions $countones $bits`) in the gate's own window | **TO-GOLDEN 2, AWAY 0 — and both moved cells are `$bits`.** Every other name untouched |
| `v174_c_homes.sv` | homes + the AWAY-risk positions: free function, free task, out-of-body constructor, function-local localparam, declaration RANGE, loop bound, case item, default argument, package/class/variable initializers | **TO-GOLDEN 4, AWAY 0**; 2 new residues found (§5) |
| `v174_d_import.sv` | THE FENCE, three import spellings: wildcard, explicit `import p::C`, and an importer that ALSO owns a class of its own | **TO-GOLDEN 6, AWAY 0** — the imported clones did not move; the importer's own class did |
| `v174_e_nonpkg.sv` | module, interface, program, `$unit` homes | **NOTHING MOVED**, byte-identical in the boundary |
| `v174_f_edge.sv` | class handle, string, chandle, event, queue, dynamic array, associative array, real, realtime | **NOTHING MOVED**; all 16 cells already equal golden |
| `v174_g_multi.sv` | 3 packages × 6 out-of-body bodies: inheritance (an inherited property read from an OOB body), a PARAMETERIZED class, a nested-class owner, an OOB task | **TO-GOLDEN 16, AWAY 0**; the arm is fully converged (36/36) |

Arm A also settles the leak question the gate raises: the IN-BLOCK twin
`Flint::innerQuery` appears **only** in the `PKGELAB` class_defn listing and is
identical on golden, pristine and patched — `bitsOutOfBlock95()` discriminates,
and `pkgClassTfClone` does not drag the in-block body in with it.

Four faces had to be dropped from arm A because **Surelog itself** rejects them
(`[ERR:UH0700]`): a bare `bit` / `logic` type operand and an inline
`logic [7:0]` / `bit [15:0]` vector type operand. Golden is unusable there, so
the vector faces are carried by typedefs and declared variables instead. A
fixed-size unpacked-array **class property** is an unsupported construct in our
own emitter and additionally **segfaults Surelog's `-elabuhdm` pass**; it is
noted, not tested here.

---

## 4. THE FENCE IS LOAD-BEARING — MEASURED, NOT ARGUED

A third binary was built with `!pkgImportCloneEmit && !importCloneEmit` deleted
and nothing else changed.

* On `v174_d_import.sv`: **AWAY-GOLDEN 12 (def) and 15 (elab)**, TO-GOLDEN 0.
* On the CORPUS, `SeqDriver/default`: **AWAY-GOLDEN 34** — 17 cells in each of
  `adpcm_pkg`'s two listings, every one an imported `uvm_packer::*` /
  `uvm_reg_block::check_data_width` clone that golden folds.

**And `uhdm-cmp` reports 33 lines on that row either way.** The fence's
necessity is *invisible to the official judge* on SeqDriver; only the census
sees it. That is the strongest single argument for the instrument, and it means
a future edit that "simplifies" the clause away would pass every gate in §6 of
RESUME.md while silently breaking 34 cells.

---

## 5. THE WIDE BOUNDARY (`BOUNDARY.r10v174.txt`)

`vbound174.sh` compiles **every** `.sv`/`.v` in the committed probe tree — top
level and subdirectories — with both frozen binaries in **both** views, reads
the list on fd 3, gives every child `</dev/null`, keys scratch on the RELATIVE
path, and asserts `PROCESSED == LISTED`.

```
LISTED=4854  PROCESSED=4854  MOVED_ARMS=13  RC_DIFFS=0   ASSERT PROCESSED==LISTED OK
```

Nine of the thirteen are the two passes' own positive controls (four
`g174_*`, five `v174_*`). The other four are other passes' arms, and each was
rebuilt against a **fresh Surelog golden** and scored in both views:

| arm | cmp pristine → patched | head | verdict |
|---|---|---|---|
| `r10buvm27repro/g27_b_shapes.sv` | 122 → 122 | same object | TO-GOLDEN 1, **AWAY 0** |
| `r10uvm95repro/g95_a3_order.sv` | 32 → 32 | same object | TO-GOLDEN 1, **AWAY 0** |
| `r10uvm95repro/g95_a5_oob.sv` | 36 → 38 | **NEW object** (`$bits`@26:9 → @28:9) | TO-GOLDEN 4, **AWAY 0** |
| `r10v95repro/v95_b3_homes.sv` | 40 → 106 def, 40 → 114 elab | **NEW object** (`sys_func_call`@35:13 → `constant`@42:12) | TO-GOLDEN 1, **AWAY 0** |

**Every row whose cmp count grew has a verified new head object**; no row grew
on the same object.

**THE MUST-STAY CONTROLS THE BRIEF NAMES ARE BYTE-IDENTICAL**, both views, all
30 arms: `r10uvm167repro` 4/0 moved, `r10uvm169repro` 4/0, `r10v169repro`
10/0, `r10uvm173repro` 4/0, `r10v173repro` 8/0. uvm169's import window is
undisturbed by measurement, not by assertion.

---

## 6. THE CORPUS CENSUS, RE-DERIVED (`CENSUS.r10v174.txt`)

Golden vs pristine vs patched on all nine movers, with the verifier's own
scorer:

| database | GOLDEN_KEEP | PRIS_KEEP | PAT_KEEP | TO-GOLDEN | AWAY | STILL-WRONG | OURS-ONLY |
|---|---|---|---|---|---|---|---|
| BuildUVMPkg ×2 | 89 | 43 | **89** | 46 | **0** | **0** | **0** |
| SimpleUVM ×2, Scoreboard | 49 | 32 | **49** | 17 | **0** | **0** | **0** |
| SeqDriver ×2, MiniAmiq ×2 | 67 | 50 | **67** | 17 | **0** | **0** | **0** |

`PAT_KEEP == GOLDEN_KEEP` on all nine: **our type-query keep set now equals
golden's, position for position**, on every UVM database. 211 cells, all
TO-GOLDEN. The implementer's closure claim is confirmed for this corpus.

**Why those 211 kept calls cost nothing at the judge:** `tf_call::Compare`
reads `Tf_call_args` and `VpiName` only, and `sys_func_call::Compare` adds
`VpiFuncType` / `VpiUserDefn` — **no span field anywhere**. The kept call's
name-only-vs-whole-call span (residue R6) is dump-only, and after the patch not
one of the 211 positions appears as a cmp difference on any row.

---

## 7. RESIDUES THE VERIFIER FOUND (ranked; both are PRE-EXISTING, neither is a regression)

* **V-R1 — an out-of-body method's FUNCTION-LOCAL LOCALPARAM initializer.**
  `v174_c_homes.sv:33`, `localparam int MIZZEN = $bits(byte);` inside
  `Bosun::hawseOut`. Golden **keeps** it in the DEF listing; we fold it, before
  and after. It sits in the gate's own window — so the family does **not** close
  in general, only on this corpus (corpus population 0, which is why the nine
  databases score STILL-WRONG 0). The gate is reached from the expression
  emitter; a localparam's initializer is emitted through the parameter path,
  which never consults `bitsKeep`.
* **V-R2 — an out-of-body method's DEFAULT ARGUMENT value.**
  `v174_c_homes.sv:27`, `function Bosun::new(input int gaff = $bits(byte));`.
  Golden **keeps**, we fold, before and after. Same window, same reason: the
  formal's default is not emitted through this site. Corpus population 0.
* Both are the *same shape* as the implementer's R4 (a package-variable
  initializer) with the sign flipped, and all three point at one open question:
  **which non-statement initializer positions the DEF listing's `Reduce::No`
  reaches.** That is the natural next decode for this family, and it is worth
  more than R2/R3/R5 because it is inside the window this pass just opened.
* The implementer's R1–R6 were each re-measured and each reproduced: R1 (the
  free-function half of the import clone — arm D's `freeForge` in all three
  importers, OURS-ONLY in both binaries), R2 (`$bits(shardKind)`/`$bits(emberIdx)`
  class-local typedef in the elaborated class body — arm A's single STILL-WRONG),
  R3, R4 (arm C's `dunnage` at 12:19, OURS-ONLY in both), R5 (arm E: the module
  home did not move, as stated), R6 (span, proved dump-only above).

## 8. THE ONE FIX

`src/ExprEmit.cpp` carried, immediately below the new gate, a five-line comment
reading *"§ bitsOutOfBlockNoReduce95 is DECODED BUT NOT SHIPPED … It is the
next head (R0)."* After this pass the predicate **is** called and that head
**is** cleared, so the comment sends the next reader after a dead head and
breaks the campaign's STATED GATE == CODE GATE rule. It is rewritten in place,
**line count preserved**, to say that the package-copy split is shipped and
that what remains open is the MODULE's `C::m` listing (residue R5).

Because only comment text changed and no line moved, the rebuilt binary is
**byte-identical** to the one every measurement above was made with
(`9b5f05dfd8e3b7688267182183b4c173` both) — the fix carries no re-measurement
risk and invalidates nothing.

## 9. FILES

`vgrid174.sh` (arm driver), `vscore174.py` (position scorer),
`vpredict174.sh` (independent mover prediction), `vbound174.sh` (wide
boundary), `ct174cen.cpp` (the census instrument, taken from the implementer's
directory and read line by line before use), `v174_[a-g]_*.sv` (the arms), and
the artifacts `GATES` / `GRID` / `CENSUS` / `BOUNDARY` / `PREDICT.*` /
`BYTEVERIFY.*` / `DUMPDIFF.Scoreboard.default.head`.
