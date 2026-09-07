# r10uvm186 — § `cloneNewArrayArgBindsOwnDecl186` — **§ `newArrayArgNoBind16` IS A HOME-LISTING LAW: A WILDCARD-IMPORT CLONE'S `new[...]` ARGUMENT BINDS ITS OWN DECLARATION** — the SeqDriver ×2 / MiniAmiq ×2 31-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `362dcfa0` |
| pristine binary | md5 `8b1777950b91feef705565e6f16e8b0a`, built from this pass's OWN worktree at a clean `362dcfa0` and frozen `chmod 555` before any sweep |
| patched binary | md5 `85be7bc529abb997bc012034c968222b`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` (ONE conjunct on the bind gate, plus a comment on the fullname half that was measured and NOT taken), `include/UhdmExporter.h` (the law) |
| probe surface | `tools/probe/r10uvm186repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default/testflags AND MiniAmiq default/testflags, 31 cmp lines, ONE `^LHS:` each, the SAME object in all four row-modes → cleared** (31 → 62 lines, still ONE head, a NEW object). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **surelog 5 / 956** — the FOUR predicted by name from the pristine databases alone, plus `Scoreboard/default`, whose ORDER-BLIND dump diff is **0 content lines** (the svunit_pkg `vpiTaskFunc` COIN, RESUME §9). **0 / 1358** uhdm2rtlil. |
| the a-priori prediction | `LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4`, cells=5 each — SeqDriver ×2, MiniAmiq ×2 and nothing else. On uhdm2rtlil `LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0`, and byteverify agrees at 0. |
| the corpus population | the direct arguments of a DYNAMIC-ARRAY `new[...]` inside a wildcard-import clone whose name is SUBROUTINE-SCOPE: **5 keys × 2 clone copies = 10 cells** per moving row-mode, in three UVM subroutines. |
| the census (nine UVM row-modes) | SeqDriver ×2 and MiniAmiq ×2 **TOWARD 5 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**; SimpleUVM ×2, Scoreboard/default and BuildUVMPkg ×2 score **TOWARD 0 / AWAY 0 / MOVED-WRONG 0** and are untouched. Calibrated golden-vs-golden-vs-golden FIRST: every column 0 but UNTOUCHED, on every row. |
| the grid (3 arms × both views) | arm A (the ARGUMENT-DECLARATION axis) **TOWARD 14 / AWAY 0 / MOVED-WRONG 0**; arm B (the LISTING axis) **TOWARD 4 / AWAY 0 / MOVED-WRONG 0**; arm C (the CLONE-CHAIN axis) **TOWARD 18 / AWAY 0 / MOVED-WRONG 0** — every one in BOTH views, each calibrated golden-vs-golden-vs-golden at every column 0 first. |
| the WIDE boundary (5049 arms × both views) | `LISTED=5049 FENCED_SKIPPED=0 PROCESSED=5049 PROCESSED-ASSERT-OK`, **MOVED 6 arm-views** — this pass's three arms and nothing else. Every § 139 / uvm180-185 / uvm82-91 / buvm3-15 / sd8-12 arm is byte-identical, including uvm184's clone-binding arms AND its receiver-kind fence, uvm185's prototype arms and both inheritance fences. |
| the patch reproduces | applied to a FRESH `362dcfa0` worktree and built there, the tree produces md5 `85be7bc529abb997bc012034c968222b` — the very binary every number above was measured on. |
| what the corpus itself fences | `bits = new[m_packed_size]` (uvm_packer.svh:475) — a CLASS PROPERTY at the identical face, eleven lines above the head — is BARE in golden's clone and stays BARE. § `newArraySubScopeSym16`'s symbol half is untouched and is what refuses it. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `362dcfa0` worktree, ran
its 23/23 goldens (`/bin/false` 0/23), and reproduced the committed baselines
row for row — surelog `937/567/48/19/10/3/2/1/1`, uhdm2rtlil `679/50/2` in both
modes, `ct8rows` PASS on all of them, status AND dump column — before a line of
code was written. `rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         31      1
SeqDriver      testflags       31      1
SimpleUVM      ×2          664681      1
Scoreboard     default         95      1
MiniAmiq       default         31      1
MiniAmiq       testflags       31      1
BuildUVMPkg    ×2              48      1
Earlgrey_0_1   default/tf   31 / 17     1
Rggen          default    CMP_EQUAL
```

The head, identical on all four row-modes (`head_pris_*.cmp`):

```
LHS (golden)
int_var: (uvm_pkg::uvm_packer::get_bytes::sz)  line:485:7-485:9
|vpiParent:
\_begin: (uvm_pkg::uvm_packer::get_bytes)      line:486:3-486:10
|vpiTypespec: -> ref_typespec -> int_typespec  line:485:3-485:6
|vpiName:sz
|vpiSigned:1
RHS: <null>
```

### DECODING THE JUDGE — which of eleven referrers it stopped on

`RHS: <null>` with a present LHS is `BaseClass.h`'s SINGULAR `SafeCompare`
naming a VALUE (RESUME §9), not the vector overload. Eleven golden objects hold
a singular `vpiActual` onto this `int_var` — the four written references to `sz`
in `uvm_packer::get_bytes` (`sz = …` at 487:3, `new[sz]` at 488:15, `i<sz` at
489:18, `sz-1` at 490:14) across the database's listings.

`ct186skip.cpp` (r10uvm184's instrument, carried forward) is what answers WHICH.
Every generated `ref_obj::Compare` opens with
`if (!context->m_visited.insert(this).second) return r;`
(`UHDM/build/generated/src/ref_obj.cpp:129`), so PRE-SEEDING a golden object
into `CompareContext::m_visited` makes the judge SKIP it and keep walking, **with
no edit to either database**. Ten of the eleven read UNCHANGED. The eleventh:

```
skip ref_obj(sz)@488:15-488:17  -> head MOVED to int_var(sz)@507:7 / <null>
     chain <method_func_call:new:488 <assignment:488 <begin:486
           <function:uvm_packer::get_bytes:484 <package:adpcm_pkg:10
           <design:work@top_tb
```

**The head is the `vpiActual` of the SIZE ARGUMENT of `bytes = new[sz]`**
(uvm-1.2 `uvm_packer.svh:488`) in the **adpcm_pkg wildcard-import CLONE
listing** — which golden binds to `int_var (sz) @485:7`, the argument's OWN
declaration, and which we leave BARE. Skipping it moves the head one method on,
to `get_ints::sz` at 507:7 — the same law's second key, which is how the family
announces itself.

### The four listings, read off the two pristine dumps

`bytes = new[sz]` is listed four times in each database. Golden and ours agree
on two of them and differ on the other two:

| listing | golden | ours (pristine) | |
|---|---|---|---|
| `package:uvm_pkg` (HOME) | **BARE** | **BARE** | § `newArrayArgNoBind16`, agreed |
| `package:adpcm_pkg` copy 1 | `int_var (sz) @485:7` | **BARE** | ← the head |
| `package:adpcm_pkg` copy 2 | `int_var (sz) @485:7` | **BARE** | ← the same cell |
| `module_inst work@top_tb` (ELAB) | `logic_net (work@top_tb.sz)` | `logic_net (work@top_tb.sz)` | § `newArrayArgHoistNet130`, agreed |

Everything else in the clone body already agrees: `sz` at 487:3, 489:18 and
490:14 is bound to that very `int_var (uvm_pkg::uvm_packer::get_bytes::sz)
@485:7` on BOTH sides — the clone binds the HOME declaration object, not a
clone-local twin. Only the `new[...]` argument was silent.

---

## 2. THE DECODED MODEL

> **§ `cloneNewArrayArgBindsOwnDecl186`.** In a WILDCARD-IMPORT **clone** of a
> package subroutine, a SUBROUTINE-SCOPE name written in a DYNAMIC-ARRAY
> `new[...]` argument list **binds its own declaration** — the home `int_var` /
> `array_var` / `io_decl` every other reference in that clone body already
> binds. At HOME it stays BARE exactly as § `newArrayArgNoBind16` says, and in
> the ELABORATED module it keeps the hoisted wire
> § `newArrayArgHoistNet130` mints. The SYMBOL half of § 16's gate is
> unchanged: a CLASS PROPERTY, a PACKAGE variable and a parameter are all
> outside the law.

**The producer.** § `newArrayArgNoBind16`'s entire decode is the **UNPARENTED
`fcall`**: `CompileHelper::compileBlockingAssignment`'s `paDynamic_array_new`
arm (Surelog `CompileHelper.cpp:4483-4498`) builds the `method_func_call` named
`new`, gives it a span and NEVER sets its `VpiParent`, while the CLASS `= new`
arm eleven lines down does (`fcall->VpiParent(assign);`). Both hand that call to
`compileTfCallArguments` as the arguments' `pexpr`, and
`CompileHelper::bindVariable` (`CompileStmt.cpp:3089`) resolves a name by
WALKING that `pexpr`'s `VpiParent` chain — which, from the dynamic-array call, is
EMPTY. `UhdmWriter::lateBinding` then fails for the same reason.

**A wildcard-import CLONE is a COPY of that tree, and the copy is PARENTED.**
Measured in the golden itself, not assumed:

```
uvm_pkg home listing        method_func_call (new) @488:11   — no |vpiParent:
work@top_tb elaborated      method_func_call (new) @488:11   — no |vpiParent:
adpcm_pkg clone copy 1      method_func_call (new) @488:11   — |vpiParent: assignment @488:3
adpcm_pkg clone copy 2      method_func_call (new) @488:11   — |vpiParent: assignment @488:3
```

With a live parent chain the walk reaches `begin (uvm_packer::get_bytes)` and
finds `sz` in its `Variables()`. That is why the clone's answer is the HOME
declaration object and why exactly the names `bindVariable` can find — a formal
(`Io_decls()`) and a subroutine-scope local (`Variables()`) — are the ones that
bind. The same asymmetry is what `ct186new.cpp` turns into its **DYN
classifier**: a call POSITION is a dynamic-array `new[...]` when ANY instance of
it in the database is unparented, which separates `d = new[n]` from
`h = new(args)` on both sides at once (measured to agree: 28 DYN rows and 18 DYN
positions in both the golden and our SeqDriver database).

**The corpus carries its own fence.** `newArraySubScopeSym16` already answers
FALSE for a class property, and golden agrees IN THE CLONE TOO:

| uvm-1.2 site | argument is | golden's clone answer |
|---|---|---|
| `uvm_packer.svh:475` `bits = new[m_packed_size]` | a CLASS PROPERTY | **BARE** |
| `uvm_packer.svh:488` `bytes = new[sz]` | a body local | `int_var (sz) @485:7` |
| `uvm_packer.svh:509` `ints = new[sz]` | a body local | `int_var (sz) @507:7` |
| `uvm_reg_map.svh:1427` `new[n]` | a body local | `int_var (n) @1424:11` |
| `uvm_reg_map.svh:1467` `new[n](local_addr)` | a body local, the COPY SOURCE at arg1 | `array_var (local_addr) @1408:20` |
| `uvm_reg_map.svh:1491` `new[n](addr)` | a FORMAL, the COPY SOURCE at arg1 | `io_decl (addr) @1405:69` |

Five keys move, the sixth at the identical face does not. Both arguments of the
copy form (`new[n](src)`) are the law's, at arg0 and arg1 alike.

---

## 3. WHAT SHIPPED

**One gate, one conjunct.** `src/ExprEmit.cpp`, the `NamedValue` bind gate:

```cpp
bool newArrayArgNoBind16 =
    newArrayArgDepth16 > 0 && newArraySubScopeSym16(nv.symbol) &&
    !pkgImportCloneEmit;
```

`pkgImportCloneEmit` is the emitter's own WILDCARD-import clone flag (set in
`src/ParamEmit.cpp` around the two clone `emitTaskFuncs` calls and nowhere
else); the EXPLICIT-import copy has a separate flag, `importCloneEmit`, which
this gate deliberately does not name (R1). Nothing else changes: the window
(`newArrayArgDepth16`), the symbol half (`newArraySubScopeSym16`), the
§ `newArrayArgHoistNet130` pool push inside the silenced branch and every other
disjunct of the gate are the laws that own them.

### The FULLNAME half — measured, and DELIBERATELY NOT TAKEN

Golden's clone also prints `vpiFullName:adpcm_pkg::uvm_packer::get_bytes::sz`
on the argument (and on `m_packed_size`, which stays bare) where we print none,
because the `NewArray` arm calls `stripRefFullNames11(mfc)` unconditionally.
Gating that call on the SAME flag makes the DEF-view clone listing
**byte-identical to golden, all 38 rows** including the fullnames. But the ELAB
view shares those objects with the MODULE-HOISTED copy, whose golden name is
`work@top186a.spandrel186.loc186`, and arm A measures **one AWAY per key** there
(`work@top186a.…` → `Stanchion186::…`). `VpiFullName` is read by NO generated
`Compare` (RESUME §9), so the axis is worth nothing to the judge and the AWAY
is not worth taking. Both measurements are recorded; the strip stays
unconditional and the clone's missing fullname is **R2**.

---

## 4. THE GOLDEN GRID — three arms, one real Surelog golden each, both views

### Arm A `g186_a_argdecl.sv` — the ARGUMENT-DECLARATION axis. TOWARD 14 / AWAY 0 / MOVED-WRONG 0, both views.

Golden binds the argument's own declaration in the wildcard clone
(`package:Stanchion186`), and the patch matches, for every one of: a function
body local, a function-level STATIC local, a FORMAL, a NAMED-begin local, an
unnamed NESTED-begin local, a TASK's body local, an OUT-OF-BODY class method's
body local and FORMAL, and BOTH arguments of the copy form `new[n](src)` with
the source a body local dynamic array and a FORMAL dynamic array. Fourteen
keys, two clone copies each.

Not moved, and correctly:

* a CLASS PROPERTY (`m_girth`) — golden BARE in the clone, the corpus' own fence;
* a PACKAGE variable, a package PARAMETER, a package LOCALPARAM and an ENUM
  CONSTANT — outside § 16's symbol half, already agreeing;
* an IN-BODY class method's cells — not cloned into the importing package's
  `Task_funcs` at all, golden and ours both BARE.

The arm's whole-dump ORDER-BLIND diff between the two binaries is **74 lines
(def) / 58 lines (elab), every single one a `|vpiActual:` marker or its target**
— no listing line, no name line, no structural line moves.

The NESTED faces (a name inside an OPERATION, a SELECT INDEX, a for-header
ITERATOR) are inside the same window and also move, and golden's clone answer
for each is what we now produce; they are not in the direct-argument census, so
they are read off the dumps in §7. `uhdm-cmp` on the arm: def 17 → 17 lines,
elab **31 → 9212** — the elab head MOVES from this arm's own copy of the corpus
head (`int_var (Gantry186::Bollard186::trim186::loc186)`, `RHS: <null>` —
CLEARED) to a both-sides `module_inst work@top186a` compare. A NEW head, not a
bigger one: the two binaries' databases differ ONLY in the `vpiActual` lines
above, so nothing the patch wrote can be the new failure — it is a pre-existing
difference the cleared mask was hiding (RESUME §9: masks cascade; the whole-dump
diff and the census are the arbiter).

### Arm B `g186_b_listing.sv` — the LISTING axis. TOWARD 4 / AWAY 0 / MOVED-WRONG 0, both views.

One declaration face read in every listing a database can hold:

| listing | golden | pristine | patched | |
|---|---|---|---|---|
| WILDCARD clone `package:Newel186` | `int_var` / `array_var` | BARE | **matches golden** | TOWARD 4 |
| HOME `package:Mullion186` | BARE + a hoisted `logic_net` | BARE + BARE | unchanged | STILL-WRONG (§130's, not ours) |
| EXPLICIT-import copy `package:Astragal186` | `int_var (loc186) @37:9` ×2 | BARE ×2 | unchanged | **R1** |
| MODULE-homed subroutine | `logic_net (loc186)` | `int_var (loc186)` | unchanged | § 16's HOME GUARD face, pre-existing |
| `$unit`-scope subroutine | BARE | BARE | unchanged | UNTOUCHED |

Arm B is the arm that PROVES the gate is the wildcard flag and not "any second
listing": the explicit-import copy sits one package away, golden treats it
exactly like the wildcard clone, and the patch does not touch it.

### Arm C `g186_c_chain.sv` — the CLONE-CHAIN axis. TOWARD 18 / AWAY 0 / MOVED-WRONG 0, both views.

The gate is a single boolean that is saved and restored around each clone
emission, so the face that could leave it stale is a clone of a clone. One home
package (`Ratchet186`, holding a free function and an out-of-body class method,
each with a size argument and a copy-source argument) is reached three ways:

| listing | how | result |
|---|---|---|
| `package:Pawl186` | `import Ratchet186::*` | clone depth 1 — **TOWARD 6** |
| `package:Detent186` | `import Pawl186::*` | clone depth 2, TRANSITIVE — **TOWARD 6** |
| `package:Escape186` | imports Ratchet186::* AND Pawl186::* | two roads to one body — **TOWARD 6** |
| `package:Ratchet186` (HOME) | — | stays **BARE**, as § 16 says |

Golden's answer in every clone listing, at every depth, is the HOME declaration
object, and the patch produces exactly that. The six STILL-WRONG cells are the
§ `newArrayArgHoistNet130` wires golden mints in this arm's home and class
listings and we do not — pre-existing, byte-identical between the two binaries.

---

## 5. THE A-PRIORI PREDICTION (over all 956 surelog + 1358 u2r databases)

`predict186.sh` replays a COMPLETED PRISTINE sweep workdir: for every row it
reads the row's OWN golden out of the row's `cmds.txt` (never guessed), runs
`ct186new` on the golden and on the PRISTINE database, and asks the law's
question of that pair alone — *is there a DYNAMIC-ARRAY `new[...]` argument key
that golden BINDS and the pristine database leaves BARE?* A row with no such key
cannot move. The predicate is a SUPERSET of the law's own gate (a database
cannot say whether a listing is a wildcard-import clone, and the predicate does
not test the symbol half either), so it can over-name and never under-name — in
particular it WOULD name an explicit-import copy (R1) if the corpus held one.

```
LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4
PREDICT default/MiniAmiq-544c7f61  cells=5
PREDICT default/SeqDriver-32af76aa cells=5
PREDICT testflags/MiniAmiq-544c7f61  cells=5
PREDICT testflags/SeqDriver-32af76aa cells=5

LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0
```

Every row that produced a pristine database was processed and every one had its
golden (`NOGOLDEN=0`), so the prediction covers the whole comparable population.
`byteverify.sh SELFCHECK=1` on the accepted patched sweeps then reported
**MOVERS 5 / 956** — those four plus the Scoreboard COIN (§6) — and
**0 / 1358** on uhdm2rtlil, matching `PREDICTED=0` exactly.

---

## 6. MOVER ATTRIBUTION, ORDER-BLIND AND NAMED

`attrib186.sh` dumps both databases with `uhdm-dump`, normalises the workdir out
and strips `id:` numbers, then diffs PLAIN and SORTED. The sorted diff is the
only sound attribution for a coin row.

| database | mode | plain | order-blind | content lines |
|---|---|---|---|---|
| SeqDriver | default / testflags | 26 / 26 | 26 / 26 | **24** |
| MiniAmiq | default / testflags | 26 / 26 | 26 / 26 | **24** |
| Scoreboard | default | 28 | **2 (the dump's own path header)** | **0** |

Every content line of the four real movers is a `|vpiActual:` marker or the
object it points at, by name — twelve markers and twelve targets:

```
int_var  (uvm_pkg::uvm_packer::get_bytes::sz)                       <- THE HEAD
int_var  (uvm_pkg::uvm_packer::get_ints::sz)
int_var  (uvm_pkg::uvm_reg_map::get_physical_addresses::n)
array_var(uvm_pkg::uvm_reg_map::get_physical_addresses::local_addr)
io_decl  (addr)
```

Nothing else in any database changed. `Scoreboard/default`'s order-blind diff has
**zero content lines** — the svunit_pkg `vpiTaskFunc` order COIN (RESUME §9,
and the predecessor r10uvm184 saw the identical row flip). A coin that lands the
other way is a measurement, not a regression, and the order-blind diff is the
only sound read of it.

---

## 7. RESIDUES AND R0

* **R0 — the next head.** SeqDriver ×2 and MiniAmiq ×2, **62 cmp lines, ONE
  `^LHS:`**, the same object in all four row-modes (id-free identical within
  each test; SeqDriver and MiniAmiq differ only in the importing package's name,
  `adpcm_pkg` vs `svaunit_pkg`). It is the RANGE of an ASSOCIATIVE ARRAY WHOSE
  INDEX IS A CLASS, in the clone listing —
  `bit predecessors[uvm_phase];` (uvm-1.2 `uvm_phase.svh:1664`, inside
  `function void uvm_phase::get_adjacent_predecessor_nodes`). Golden writes the
  range bound as a `constant` with `vpiDecompile:associative`, `STRING:associative`,
  `vpiConstType:6` and a `ref_typespec -> class_typespec (uvm_phase)`; we write
  an `operation` (`vpiOpType:11`) over `ref_obj (uvm_phase)` and a
  `constant INT:1`. A both-sides compare, not a `<null>`. `head_pat_*.cmp`.
  (SimpleUVM's own cmp log is the 664681-line depth artifact and is deliberately
  not carried here.)
* **R1 — the EXPLICIT-import copy.** `import P::fn;` produces a copy that golden
  binds exactly like the wildcard clone (arm B, `package:Astragal186`, one key ×
  2 copies, both views), and this law does not fire there because its gate is
  `pkgImportCloneEmit`, the WILDCARD flag. **Corpus incidence: zero** — the
  superset predictor, which cannot tell the two apart, names no such cell in
  956 + 1358 databases. (r10uvm184's R1 is the same face for its own law.)
* **R2 — the clone's `vpiFullName`.** Golden keeps the clone-scoped fullname on
  a clone's `new[...]` arguments and we strip it. Taking it costs one AWAY per
  key in the ELAB view (§3); `VpiFullName` is read by no generated `Compare`, so
  the whole axis is invisible to the judge. Corpus incidence: every one of the
  ten moved cells, plus the `m_packed_size` cell that stays bare.
* **R3 — the SELECT BASE and the FOREACH INDEX under a `new[...]` in a clone.**
  Arm A, def view: for `new[idxbag186[loc186]]` golden binds the `bit_select`
  base to `array_var (idxbag186)` in the clone and we leave it BARE; for
  `new[fex186 + 1]` under a `foreach`, golden binds the index to a `ref_var` and
  we leave it BARE. Both are BARE in the pristine binary too — STILL-WRONG, not
  AWAY — and neither is a direct `Tf_call_args` element, so neither is in this
  law's population. The nested faces that ARE plain names (an OPERATION operand,
  a SELECT INDEX, a for-header ITERATOR) all move to golden's clone answer.
* **R4 — the `this` implicit argument of a CLASS `new(...)`.** Nine keys in
  `package:uvm_pkg+cls` where golden's `logic_net (this)` is spanned at
  `uvm_phase.svh:902:36` and ours at the call site (`152:45`, `228:47`, …).
  Identical pristine and patched; a CLASS-constructor face (`CLS`), not this
  law's, and the census reports it as STILL-WRONG 9 on SeqDriver.
* **R5 — the `create` line-number residue.** `ONLY-GOLDEN 2 / ONLY-OURS 2` on
  SeqDriver and MiniAmiq are one macro-expanded `create(name)` construct that
  golden spans at `414:21` and we at `418:21`; every cell BARE on both sides,
  `ONLY-OURS-MOVED 0`, identical pristine and patched.
* **R6 — the HOME listing's select-index fullname.** For `new[idxbag186[loc186]]`
  the inner index ref carries `Gantry186::spandrel186::loc186` in our HOME
  listing where golden carries none (`stripRefFullNames11` does not recurse into
  a `bit_select`'s index). Pre-existing, unchanged by this pass, dump-only.

---

## 8. REPRODUCING

```sh
g++ -O2 -std=c++17 ct186new.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186new
g++ -O2 -std=c++17 ct186skip.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186skip
g++ -O2 -std=c++17 ct186own.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186own

./ct186skip <golden.uhdm> <ours.uhdm>            # WHICH referrer the judge stopped on
./ct186own  <golden.uhdm> <ours.uhdm> [scope] [var]   # the head's owner, both directions
./ct186new  <db.uhdm> [name-substr]              # the `new[...]` argument census (DYN/CLS)
CT186NEW=./ct186new ./grid186.sh g186_a_argdecl.sv <pris.bin> <pat.bin> <workdir>
CT186NEW=./ct186new ./grid186.sh g186_b_listing.sv <pris.bin> <pat.bin> <workdir>
CT186NEW=./ct186new ./grid186.sh g186_c_chain.sv   <pris.bin> <pat.bin> <workdir>
python3 score186.py <wd>/mfc.g.<view>.txt <wd>/mfc.a.<view>.txt <wd>/mfc.b.<view>.txt
CT186NEW=./ct186new ./predict186.sh <PRISTINE workdir> <out.txt>
CT186NEW=./ct186new ./cenall186.sh  <pris wd> <pat wd> <outdir> SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg
./attrib186.sh <pris wd> <pat wd> <outdir> 'SeqDriver|MiniAmiq|Scoreboard'
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=/tmp/r10uvm186_bound ./bound186.sh
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ../r10oth4repro/byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
bash canaudit.sh canaries.sh ctcan2.sh
```

Arms A, B and C must read **AWAY 0 and MOVED-WRONG 0 in both views**, and the
arms' whole-dump order-blind diff between the two binaries must contain
`|vpiActual:` lines and their targets and nothing else.
