# r10det1 — is the UVM alias/typespec population BUILD-DEPENDENT?

**Result, up front: the brief's hypothesis is REFUTED, and the real cause is
named.**

* **The population is NOT build-dependent.** SEVEN binaries measured. Every
  binary built from the SAME SOURCE gives the IDENTICAL population, and four
  different binaries at base commit `3500bc4` produce a **BYTE-IDENTICAL**
  BuildUVMPkg database (`4e99f0754d13be98d76bfc109f401683`).
* **The r10oth8 F1 hunk is not the cause.** Reverting it — at `3500bc4` and again
  on r10oth8's own shipped binary `51bb84bc…` — moves **NOTHING**: same alias
  count, same class_typespec count, same object total, and at `3500bc4` the same
  database byte for byte.
* **The pointer-keyed-map mechanism is REFUTED as the cause.** A semantically
  null heap perturbation inside ONE binary demonstrably permutes the
  address-ordered iteration (**408** order lines under a single 48-byte leaked
  block, **8190** under 12.8 MB) and the population does **not** move: ALIAS
  337 / CTS 6371 / TOTAL 180805 in every arm, all 132 typespec listing vectors
  identical, and **`uhdm-cmp` reports the two databases EQUAL**.
* **The real cause of r10oth8 §0.1's "+98 aliases out of a semantically-null
  edit": a SECOND LAW that landed in the SAME COMMIT.** `37ffbd2` carries both
  `§ arrayVarSignedWritten8` *and* `§ classNestedClassTdGroupNoAnchor54` /
  `drainClassNestedTdGroups54()`, whose entire job is to hang `Typedef_alias`
  refs on class_typespec clones. The +98 is **all class_typespec** (34 → 132
  carriers, object count unchanged at 6371). r10oth8 compared a binary from
  before that law with one from after it and attributed the difference to its own
  F1 fix. **A misattribution, not a mystery.**
* **The convergence gap is UNRELATED to any ordering.** Our 337 vs golden's 1069
  aliases on BuildUVMPkg is **73 % missing `bit_typespec` carriers** (790 vs 141)
  next to **667 missing `bit_typespec` OBJECTS** (2014 vs 1347). It is a missing
  population, not a wrong pick. `class_typespec` carriers are effectively matched
  (golden 131, ours 132). No stable-key change can close it.
* **What the pass DID find is a real nondeterminism bug, with its mechanism
  proven and its direction measured: `§ unitImportOrderBufRank1`.**
  `unitScopeWildcardImports()` sorted unit-scope wildcard imports with the RAW
  `SourceLocation::operator<`, which compares BufferIDs — assigned in parallel-load
  completion order. Scoreboard's two imports live in two files, so the 917-entry
  `design->vpiTaskFunc` listing **flipped run to run out of ONE binary**, and
  **GOLDEN is the order the coin flip loses half the time**. The fix is the
  emitter's own `srcOrderLess`.

Base commit `3500bc4`, branch `auto5h`. **LHS is ALWAYS golden (Surelog); RHS is
ALWAYS ours**, in every table below and in every script.

---

## 0. THE SEVEN BINARIES, and the population each produces

Every md5 below was built by me in my own worktree. Three of them reproduce
md5s recorded by earlier passes **bit for bit**, which is how I know the
historical binaries are the ones I think they are.

| # | tree | md5 | note |
|---|---|---|---|
| P | `3500bc4` pristine | `71bd294b421e23a4feb7807f8c5b7a8f` | **equals the committed `build/slang-uhdm`** |
| I | `3500bc4` + instrument | `7eb9ab8d9e006b69922498175a9b31d2` | env-guarded pad + order dump |
| R | `3500bc4` + F1 reverted | `192a8c5bf28c67d409b36afffe9e9c5f` | experiment **E1** |
| IR | `3500bc4` + instrument + F1 reverted | `66ecbc40b0b6b4a9f714448ca0e96515` | E1 with the instrument |
| S | `37ffbd2` as landed | `51bb84bca8a60e0e0b886a615a761322` | **= r10oth8's recorded "shipped"** |
| S− | `37ffbd2` + F1 reverted | `5e54a298ec7a36ad57143d700d98d892` | r10oth8's "patched" content, **E3** |
| Z | `8d4d6ed` | `2e27ef16b664eca1e5bdbfaa2ce5c365` | **= r10oth8's recorded "pristine"** |

**Population, counted as OBJECTS** (`dtpop`, walking `Serializer::AllObjects()`),
`--jobs 1`, surelog corpus, default mode:

| binary | BuildUVMPkg alias | CTS | TOTAL | SeqDriver alias | CTS | TOTAL |
|---|---|---|---|---|---|---|
| **golden** | **1069** | **5932** | **183142** | **1709** | **9748** | **317210** |
| Z `8d4d6ed` | 239 | 6371 | 180692 | 361 | 8789 | 298305 |
| S− `37ffbd2`−F1 | **337** | 6371 | 180790 | 426 | 8789 | 298370 |
| S `37ffbd2` | **337** | 6371 | 180790 | 426 | 8789 | 298370 |
| P `3500bc4` | **337** | 6371 | 180805 | 426 | 8789 | 298387 |
| R `3500bc4`−F1 | **337** | 6371 | 180805 | 426 | 8789 | 298387 |
| I, IR | 337 | 6371 | 180805 | — | — | — |

Scoreboard, P and R alike: alias 316, CTS 6122, TOTAL 183568 (golden 965 / 5848 /
187081).

**Read the S− row against the S row.** They differ by exactly the r10oth8 F1
hunk and they agree in every column. **E1/E3: the F1 hunk moves the population by
ZERO**, on the very binary pair the claim was made about.

**Read the Z row against the S− row.** THAT is where 239 → 337 happens: between
`8d4d6ed` and `37ffbd2`, i.e. across the r10oth8 COMMIT, with F1 already
excluded. §3 identifies what inside that commit did it.

### 0.1 The instrument that made this cheap, and the measurement-law correction it forced

r10oth8 §0.1's `class_typespec` column (golden 12671, ours 12948/13144) is **dump
occurrences, not objects**. Measured here on the same test:

```
vpiTypedefAlias dump-occurrences: 337        (objects: 337 — the two AGREE)
class_typespec  dump-occurrences: 13140      (objects: 6371 — inflated 2.06x)
uhdm-dump --stats class_typespec: 6371       (agrees with dtpop to the unit)
```

So the alias column of that table is quotable and the `class_typespec` column is
not. My `13140` at `3500bc4` versus their `13144` at `51bb84bc` is four dump
occurrences, not 196 objects. **The alias metric is instrument-independent; the
typespec metric is not.** `dtpop` counts objects and is the instrument used
everywhere below.

---

## 1. THE INVENTORY (job 1) — pointer-keyed containers that are ITERATED

Enumerated mechanically, not from the brief's list
(`scratchpad/inv.py`, reproduced in §9): **176** member containers in
`include/UhdmExporter.h` are keyed on a pointer or a `const void*`. **27 of them
are ITERATED** (not merely looked up), at **67 sites**, and `Serializer::AllObjects()`
— `std::map<const BaseClass*, uint32_t>`, `~/.local/include/uhdm/Serializer.h:87`,
i.e. **ADDRESS-ORDERED** — is iterated at a further **15**. **82 address-ordered
iteration sites in total.**

The brief's three tables are real, at these lines in the shipped tree (its line
numbers were from an older commit):

| table | declaration | iterated at |
|---|---|---|
| `typedefTs` | `std::map<const slang::ast::Symbol*, UHDM::typespec*>`, `include/UhdmExporter.h:2595` | **30 sites**: `src/ModuleEmit.cpp:4488,13248,26291`; `src/ParamEmit.cpp:17877,17998,18426,18452,18682,19022`; `src/TaskFuncEmit.cpp:2768,2797,3020,3141,3940`; `src/TypeEmit.cpp:1468,4468,6009,6724,7366,7491,7524,7576,7868,9594,14898,15009,15304,15339,15571,15595` |
| `pkgTopTypedefTs` | `std::map<const void*, UHDM::typespec*>`, `include/UhdmExporter.h:3495` | `src/TypeEmit.cpp:7369,7493,7526` |
| `bareScalarTdCopy` | `std::map<const UHDM::typespec*, UHDM::typespec*>`, `include/UhdmExporter.h:505` | `src/TypeEmit.cpp:7753` |

The other 23 iterated containers, with their declaration line and site count:
`defMap` 1824 (3), `subMap` 2585 (2), `unbasedOvConst` 3727 (2), `pkgTopMap` 3457
(2), `pkgParamDefRhs` 3924 (2), `elabParamConst` 3717, `elabParamPa` 3720,
`castUnionClone` 612, `classRep25` 3063, `classDefnMap` 2952, `attrMap` 2680,
`importedTfCalls` 2407, `unitParamMap` 3267, `pkgParamConst` 3835,
`pkgWildcardCloneTf` 2348, `pkgParamObj` 3838, `pkgImportCloneTfs16` 559,
`pkgCloneHomeSub17` 580, `pkgBoundMintTs17` 475, `pkgImportCloneOwner32` 3957,
`enumAliasHomeOwner36` 550, `pkgImportCloneTs` 3947 (2 — one of them a
line-broken range-for at `src/ParamEmit.cpp:17212` that a single-line grep
misses), `enumConstMap` 2663, `classRecvCallHp39` 2378.

### 1.1 WHICH are order-SENSITIVE IN THEIR RESULT — the distinction the brief asked for

**ORDER-NEUTRAL, proved by reading the body, not assumed:**

* `src/TypeEmit.cpp:7366`/`:7369` — both loops do nothing but
  `listingTs.insert(ts)`. `listingTs` is only ever asked `.count(t)`, so the
  RESULT is a set membership test: **insertion order cannot change it.**
* `src/TypeEmit.cpp:7491`/`:7493` — same shape into `aliasOfAlias`, read only via
  `.count(ts)`. **Order-neutral.**
* `src/ParamEmit.cpp:19218` (`for (auto& [k9,i9] : base9)`) — one write per
  distinct key, and the value written was already picked by NAME with an index
  tie-break (`:19206-19216`). **Order-neutral**, which is why the
  `§ pkgClassTd9` base/alias pick is NOT part of this story.

**ORDER-SENSITIVE BY CONSTRUCTION — a REVERSE LOOKUP BY VALUE with `break`, over
an address-ordered map.** Two symbols legitimately share one typespec object in
this emitter (that is what `bypassTypedefShare` exists for), so WHICH key wins is
decided by address order, and the winner selects the emitted pointer:

* `src/ModuleEmit.cpp:4488` — `if (tsp9 == al9->Actual_typespec()) { tdSym9 = sy9; break; }`, then `al9->Actual_typespec(tt9->second)`. **An emitted field.**
* `src/ParamEmit.cpp:18426` — `if (tsp9 == mts) { homeSym9 = sym9; break; }`, then `tm->Typespec()->Actual_typespec(cit9->second)`. **An emitted field.**
* `src/ParamEmit.cpp:17877`, `:19022`, `src/TypeEmit.cpp:15339` — first-wins by
  CANONICAL TYPE or by SYNTAX NODE, which can match many symbols at once; each
  feeds an `Actual_typespec` / `Elem_typespec`.

**ORDER-SENSITIVE, LAST-WINS:** `src/TypeEmit.cpp:7524` then `:7526` write
`pkgScalarTdHome36[ts]` from `typedefTs` and then from `pkgTopTypedefTs`; for a
SHARED `ts` the second loop overwrites the first. Same shape at `:6009`, `:6724`,
`:7576`, `:7868`.

**AND YET NONE OF IT MOVES THE POPULATION — §2 shows why.** The KEY SPACE of the
sensitive tables is `slang::ast::Symbol*`, and slang allocates symbols from a
**`BumpAllocator`** (`~/.local/include/slang/util/BumpAllocator.h:19` "Allocates
items sequentially in memory"), so their RELATIVE address order is allocation
order — a function of the source and the compilation path, **not of the heap**.
Measured: under a perturbation that moved 8190 `AllObjects` order lines, the
`typedefTs` iteration order changed by **0 lines of 234** and `pkgTopTypedefTs`
by **0 of 89**.

---

## 2. THE CONTROLLED EXPERIMENT (job 2) — ONE BINARY, FOUR HEAP LAYOUTS

`dtperturb.sh` runs the INSTRUMENTED binary `I` several times under
`R10DET1_PAD=<count>[:<bytes>]`, which leaks that many blocks before the first
UHDM allocation and is read by nothing. Same bytes, same code path, only the
arena moved — **no build term at all**, which is what every earlier attempt at
this question was missing.

```
BINARY=…/r10det1i/build/slang-uhdm md5=7eb9ab8d9e006b69922498175a9b31d2   TEST=BuildUVMPkg

pad=none         db_md5=4e99f0754d13be98d76bfc109f401683  ALIAS=337 CTS=6371 TOTAL=180805
   n=180652 lo=0x5c3d5e20100 hi=0x70c11232fee0 design=0x5c3da1c1f80
pad=0:0          db_md5=4e99f0754d13be98d76bfc109f401683  ALIAS=337 CTS=6371 TOTAL=180805
   n=180652 lo=0x5c3d5e20100 hi=0x7001ff6cfee0 design=0x5c3da1c1f80
pad=1:48         db_md5=4e99f0754d13be98d76bfc109f401683  ALIAS=337 CTS=6371 TOTAL=180805
   n=180652 lo=0x5c3d5e20100 hi=0x71331bdbfee0 design=0x5c3da1c1f80
pad=200000:64    db_md5=51159c34c5f7af5102854b8ea2cf83ca  ALIAS=337 CTS=6371 TOTAL=180805
   n=180652 lo=0x5c3d5e20100 hi=0x799784d7fee0 design=0x5c3da1c1f80

=== ORDER DIFFS vs the first arm (source identities only, no addresses) ===
allobj pad=0:0:         0 differing order lines vs BASE (180652 entries)
allobj pad=1:48:      408 differing order lines vs BASE (180652 entries)
allobj pad=200000:64: 8190 differing order lines vs BASE (180652 entries)
tdts   every arm:       0 differing order lines vs BASE (234 entries)
pkgtop every arm:       0 differing order lines vs BASE (89 entries)
```

Four things this establishes, and one trap it avoided:

1. **`none` vs `0:0` is the NULL CONTROL** (`R10DET1_PAD=0:0` takes the same
   `getenv` path and allocates nothing): byte-identical database, 0 order lines.
   **So the run is deterministic and the churn below is the pad, not ASLR.**
   Without this arm every number here would be unfalsifiable, because `hi`
   differs in EVERY arm — that is the mmap region, which ASLR moves per run
   regardless. `lo` (the brk region) is identical in all four arms.
2. **ONE 48-byte leaked block permutes 408 iteration positions.** Address
   sensitivity of the iteration is proven outright.
3. **The population does not move in ANY arm.** 337 / 6371 / 180805 four times.
4. **`pad=1:48` produced a BYTE-IDENTICAL DATABASE** while its iteration order
   differed by 408 positions. That is the cleanest single fact in this document:
   the address order changed and **not one output byte** followed it.

**INSTRUMENT CORRECTION worth keeping:** the pass's first pad was a single
256 KiB block, and it moved NOTHING — glibc serves one allocation ≥128 KiB
(`M_MMAP_THRESHOLD`) by mmap, so it does not shift the main arena at all. A pad
must be a COUNT of SMALL blocks. `dtperturb.sh` prints the `ADDRPROOF` line and
flags any arm whose addresses match the base arm as `PAD-INERT`, so an inert arm
can never be read as evidence of insensitivity.

### 2.1 What the 12.8 MB pad DID change, characterised to the line

`pad=200000:64` is the only arm whose database md5 differs. It differs by
**26 diff lines that are ONE 12-line block MOVED 87 lines later** — an
`int_typespec (uvm_action) 8075:9` printed in a different position — with
**identical text**:

* `uhdm-cmp db_none db_pad` → **rc=0, ZERO output: the two databases are EQUAL**
  to the authoritative comparator.
* sorted dumps are identical → **multiset-identical**.
* all **132** typespec listing vectors byte-identical in ORDER (`dtvec`).
* the restored object sequence and the id assigned to every source identity are
  identical (`dtpop --ids`, 180805 lines, 0 differing).

So the effect of a proven address-order change on the emitted database is: a
single object's print position in `uhdm-dump`'s output, invisible to `uhdm-cmp`.
**Residue R3** below — I did not identify the container that carries it, and I
say so rather than guessing.

**PROBE BUG WORTH RECORDING (it produced a false negative first):** `dtvec`'s
first version keyed each listing on `kind|name|line:col`. A design carries a DEF
and a TOP `uvm_pkg` with the **same name and the same span**, so that key
collided and the map silently kept whichever came first **in address order** —
the probe dropped one vector and reported "no difference" from a comparison it
had not made. Rewritten to emit one line per vector and compare the whole set as
a multiset (132 vectors, not 131). **A probe keyed on a non-unique identity is
the same bug class this pass was sent to investigate.**

---

## 3. THE REAL CAUSE OF 239 → 337 (job 3, and the answer the brief wanted)

`git diff 8d4d6ed 37ffbd2 -- src include` is **`src/UhdmExporter.cpp +262`**,
`src/TypeEmit.cpp +29`, `include/UhdmExporter.h +44`. The `+262` is not the
`vpiSigned` law. It contains:

```
+// NOTE § classNestedClassTdGroupNoAnchor54 — the drain.  DIRECTION: RESHAPE
+void UhdmExporter::drainClassNestedTdGroups54() {
…
+            m54.ts->Typedef_alias(ar54);
```

**A law whose entire purpose is to hang `Typedef_alias` refs on class_typespec
clones landed in the same commit as the F1 fix.** The alias delta is exactly that
shape — carriers per kind, BuildUVMPkg, `dtalias`:

| kind | Z `8d4d6ed` carriers | P `3500bc4` carriers | objects Z → P |
|---|---|---|---|
| **class_typespec** | **34** | **132** | 6371 → 6371 (unchanged) |
| bit_typespec | 141 | 141 | 1347 → 1347 |
| int_typespec | 14 | 14 | 2627 → 2622 |
| logic_typespec | 47 | 47 | 83 → 83 |
| enum / array | 2 / 1 | 2 / 1 | unchanged |

**+98 aliases, ALL of them on class_typespec, with the class_typespec object
count unchanged.** 98 existing objects GAINED an alias. That is
`drainClassNestedTdGroups54` doing exactly what it was written to do — a
**semantic** change, correctly attributable to a named law, and NOT to F1 (whose
own revert moves nothing, §0) and NOT to allocation order (§2).

**VERDICT ON THE BRIEF'S HYPOTHESIS: REFUTED, in both halves.**
"A semantically-null edit shifted the population" — the edit that shifted it was
a semantic alias-adding law; the null edit shifts nothing.
"The emitter keys typespec/alias tables on pointers and iterates them, so a
different order makes a different object win" — the tables and the first-wins
reads are real (§1.1) but their key space is arena-allocated and
perturbation-invariant, and a perturbation that DID move the UHDM address order
moved no output that `uhdm-cmp` can see (§2).

**CONSEQUENCE for the campaign, replacing r10oth8 §0.1's warning:** a UVM alias
census IS reproducible. It is a function of the SOURCE. Two agents in two
worktrees measuring the same commit with the same instrument must agree, and if
they do not, one of them has an instrument bug (dump occurrences vs objects is
the standing trap: 337 is quotable, 13144 is not). What r10oth8 §0.1 called an
unquantified build term does not exist.

---

## 4. WHAT DOES MOVE RUN TO RUN — and it is a REAL BUG (`§ unitImportOrderBufRank1`)

Scoreboard, ONE binary (P), 3 reps, `--jobs 1`:

```
Scoreboard  aliasG 965  aliasO 316  ctsG 5848  ctsO 6122  totalG 187081  totalO 183568   (rep 1)
Scoreboard  aliasG 965  aliasO 316  ctsG 5848  ctsO 6122  totalG 187081  totalO 183568   (rep 2)
Scoreboard  aliasG 965  aliasO 316  ctsG 5848  ctsO 6122  totalG 187081  totalO 183568   (rep 3)
db md5: a323efb9f55a…  b3731a93f51f…  a323efb9f55a…
```

**The POPULATION is stable across reps; the BYTES are not.** (Determinism claims
name their test: BuildUVMPkg is byte-stable here — `none` vs `0:0` identical —
Scoreboard is not, confirming r10oth9 F2.) Characterised:

* `uhdm-cmp rep1 rep2` → **rc=0, zero output: EQUAL.**
* dumps: **94 content lines, sorted-identical** (`227194402125b1581e593a581dfad5ea`
  both) — a **pure permutation**.
* `dttf` names the vector exactly: **`design->Task_funcs()`, 917 entries**, whose
  head is `uvm_hdl_check_path…` in rep 1/3 and `get_name…` (svunit_pkg) in rep 2.

**The mechanism, and it is one line.** `src/ModuleEmit.cpp:3113`
(`unitScopeWildcardImports()`):

```cpp
std::stable_sort(hits.begin(), hits.end(),
                 [](const auto& a, const auto& b) { return a.first < b.first; });
```

`slang::SourceLocation::operator<` compares **(BufferID, offset)**, and BufferIDs
are assigned in parallel-load completion order — the emitter's own
`srcOrderLess` was written for exactly this and says so at
`src/UhdmExporter.cpp:2866`: *"BufferIDs follow parallel-load completion order,
which flips run to run"*. Scoreboard has its two unit-scope imports in two
different files —

```
third_party/tests/Scoreboard/design.sv:1:    import uvm_pkg::*;
third_party/tests/Scoreboard/testbench.sv:2: import svunit_pkg::*;
```

— so the pairwise compare is a **coin flip**, and it decides the order of the two
materialized groups (uvm_pkg's 894 + svunit_pkg's 23 = 917).

**AND THE COIN FLIP IS WRONG SOME OF THE TIME:**

| | head of the 917-entry `design->vpiTaskFunc` |
|---|---|
| **GOLDEN** | `uvm_hdl_check_path@59:3 uvm_hdl_deposit@67:3 …` |
| ours rep 1/3 | `uvm_hdl_check_path@59:3 uvm_hdl_deposit@67:3 …` ✅ |
| ours rep 2 | `get_name@68:1 report@77:1 …` ❌ |

Golden is uvm-first = **command-line order** (`design.sv` precedes
`testbench.sv`), which is precisely what `srcOrderLess`'s buffer rank yields. So
replacing the raw comparator with `srcOrderLess` is **not** "stabilising at an
arbitrary order" — it stabilises at GOLDEN's order. `§ unitImportOrderBufRank1`
is the law, marked at the one call site.

### 4.1 The determinism, MEASURED, 6 reps each on one test named out loud

Scoreboard/default, `--jobs 1`, one `slang.uhdm` md5 per rep:

| binary | rep md5s | distinct |
|---|---|---|
| PRISTINE `71bd294b` | `a323efb9` ×4, `b3731a93` ×1, `cfe85c11` ×1 | **3** |
| PATCHED `943bb43d` | `a323efb9` ×6 | **1**, and it is **GOLDEN's order** |

Two things to be careful about, both stated rather than glossed:

* **`cfe85c11` is a THIRD draw** the 3-rep run in the table above never produced.
  So the pristine listing has **at least three** reachable states, and the two I
  characterised in §4 are not the whole story — there is at least one more degree
  of freedom in that listing, unidentified.
* **6/6 is 6 reps, not a proof of determinism.** The claim I make is: the
  comparator that provably flips is gone, and the patched binary drew one value
  six times where the pristine binary drew three values in the same six. I did
  not run enough reps to say the row can never flip again, and `cfe85c11` is the
  reason to keep saying so. **Residue R7.**

---

## 5. PRICING THE BRIEF'S PROPOSED FIX (job 4) — and why it is NOT worth shipping

**Does golden's own order look like SOURCE order?** No — **NAME order**, and we
already match it. `uvm_pkg`'s 89-entry package `Typespecs` listing in golden is
**strictly ASCII name-sorted** (`sort -c` passes), and our sequence is
**identical, 0 differing positions of 89**. There is nothing for a stable key to
buy in the listing order.

**Is the missing alias population about which object wins?** No. BuildUVMPkg,
carriers by kind (`dtalias`, objects):

| kind | golden carriers | ours | golden objects | ours |
|---|---|---|---|---|
| **bit_typespec** | **790** | **141** | **2014** | **1347** |
| int_typespec | 91 | 14 | 2236 | 2622 |
| logic_typespec | 55 | 47 | 78 | 83 |
| class_typespec | 131 | **132** | 5932 | 6371 |
| enum_typespec | 2 | 2 | 74 | 75 |
| array_typespec | 0 | **1** | 485 | 584 |
| **total** | **1069** | **337** | | |

**649 of the 732 missing aliases (89 %) are `bit_typespec` carriers, alongside
667 MISSING `bit_typespec` OBJECTS.** We do not mint the objects, so we cannot
alias them. `class_typespec` is already at parity (131 vs 132 — one over-fire,
ranked R2). **A stable key cannot close a missing-population gap**, and it would
stabilise an order that is already stable (§2: `typedefTs` 0/234,
`pkgTopTypedefTs` 0/89 under perturbation).

**PRICE, for the record:** a stable key on `typedefTs` / `pkgTopTypedefTs` /
`bareScalarTdCopy` means touching **34 iteration sites** plus every insertion
site, and the honest expected yield is **zero** — no convergence (§5), no
reproducibility (§2 shows they are already reproducible), against a large blast
radius across the region every UVM pass is working in. **Recommendation: DO NOT
DO IT.** The brief's own criterion ("ship it only if…") is not met, and the
container it would harden is not the one that moves.

---

## 6. WHAT SHIPPED, AND THE GATE TRANSCRIPT

`§ unitImportOrderBufRank1` is a ONE-comparator change in
`unitScopeWildcardImports()` (`src/ModuleEmit.cpp`), whose only caller is
`src/UhdmExporter.cpp:4819` (the `design->Task_funcs()` append). It can only
change a design with **two or more unit-scope wildcard imports in different
buffers**. Pristine `71bd294b421e23a4feb7807f8c5b7a8f` → patched
`943bb43d7849838ae462f636f8b31020`.

**GATE 1 — BUILD.** `[100%] Linking CXX executable slang-uhdm` /
`[100%] Built target slang_uhdm` in the output, and the md5 asserted CHANGED in a
separate command with both md5s length-checked at 32 hex chars
(`MD5 CHANGED: OK`).

**GATE 2 — GOLDENS.** `23 PASS / 0 FAIL`. Negative control
`SLANG_UHDM=/bin/false`: `0 PASS / 23 FAIL`.

**GATE 3 — u2r testflags, `--jobs 2`.** `679 CMP_EQUAL / 50 SLANG_REJECT /
2 SURELOG_FAIL`; dump `496 match / 183 differ / 52 blank`. Whole-row judge
(`ct8rows.sh` against the committed `results/gate_uhdm2rtlil.csv`):
**731 ROWS, 0 differing ROWS**, `PASS: every row byte-identical to the committed
baseline`.

**GATE 4 — surelog `--mode both --jobs 2`.** default `467 CMP_EQUAL /
13 CMP_NOTEQUAL`, testflags `463 CMP_EQUAL / 10 CMP_NOTEQUAL`, `5 DEFERRED` in
each (GOLDEN_DEFER left at its default). Dump: default `225 match / 242 differ`,
testflags `165 match / 298 differ`. Whole-row judge against the committed
`results/golden_surelog.csv`: **1588 ROWS, 0 differing ROWS**, `PASS`.
(The pristine binary was swept first and its CSVs are **byte-identical to both
committed baselines** — that is the control that the sweeps themselves are sound.)

**GATE 5 — BYTE VERIFIER**, `SELFCHECK=1 SELFCHECK1=1`, patched vs a pristine
`3500bc4` workdir I built and swept myself:

```
u2r:      PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
          SELFCHECK 678/679 flagged      SELFCHECK1 -> 1
surelog:  PATH_SETS_IDENTICAL (953 paths)   MOVERS: 1 / 953
          MOVER ./default/Scoreboard-59431470/slang.uhdm
                patched=a323efb9f55a  pristine=b3731a93f51f
          SELFCHECK 952/953 flagged      SELFCHECK1 -> 2 (1 corruption + the 1 real mover)
```

**THE ONE MOVER IS THE LAW, attributed by CONTENT** (`ct9movers.sh`): every
distinct changed line shape appears **once as `-` and once as `+`** — `23
-|vpiTaskFunc:` / `23 +|vpiTaskFunc:` plus the 23 svunit_pkg task/function
headers — i.e. a **pure permutation of svunit_pkg's 23 entries** from the head of
the 917-entry listing to after uvm_pkg's 894. **Zero `class_typespec` and zero
`vpiTypedefAlias` lines.** And the two md5s are exactly the two draws of §4's
coin flip, with the patched side landing on GOLDEN's order.

**CANARIES**, all `changed=0 absent=0`:

```
ctcan2.sh   u2r     EXPECT_UNKNOWN=6  -> ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh   surelog EXPECT_UNKNOWN=1  -> ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaries.sh (r10uvm52repro) surelog   -> ok=52 changed=0 absent=0
canaries.sh (r10uvm52repro) u2r       -> ok=8  changed=0 absent=0
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
             (UnsignedParam / HierPathEval / FileLocalParam / TopParam: not
              dispatched by any driver — the fence held)
```

**BY NAME, both modes, baseline → fresh, byte-identical:**

```
InterfaceModPort    default CMP_EQUAL/differ   testflags CMP_EQUAL/differ
BlackParrotComplex  default CMP_EQUAL/differ   testflags CMP_EQUAL/differ
```

Both are inside the byte verifier's 953 paths and neither is a mover, so their
databases are byte-identical too.

**WHAT THIS CHANGE BUYS, stated plainly:** it removes a comparator that drew the
WRONG listing order on some runs, so it is a **convergence** fix and not merely a
reproducibility one — but its convergence effect on the SCOREBOARD it fixes is
**zero rows**: Scoreboard/default was `CMP_NOTEQUAL` before and stays
`CMP_NOTEQUAL` (its dump column is blank in the baseline, so the row could not
have registered the difference either way). **0 movers on u2r, 1 on surelog, 0
rows changed status or dump on either corpus.**

---

## 7. RANKED RESIDUE

**R1 — `bit_typespec` alias/object shortfall on the UVM tests. 667 missing
objects, 649 missing alias carriers, BuildUVMPkg alone.** This is the whole
alias gap (89 % of 732) and it is a MISSING POPULATION, not an ordering or a
pick. Golden carries 2014 `bit_typespec` objects and 790 of them alias; we carry
1347 and 141. The next pass on UVM aliases should start here, with the shape
census in §5 as the instrument, and should NOT start from the alias total.

**R2 — one over-firing `array_typespec` alias carrier on BuildUVMPkg (golden 0,
ours 1), and one extra `class_typespec` carrier (golden 131, ours 132).** Two
objects; cheap to localise with `dtalias` plus a span grep. Worth doing because
`class_typespec` is otherwise at parity and an over-fire there will be mistaken
for progress by a total-only census.

**R3 — the container behind the 12.8 MB-pad print-position move (§2.1) is
UNIDENTIFIED.** One object moves position in `uhdm-dump`'s output while
`uhdm-cmp` says EQUAL, all 132 typespec listing vectors are identical, and the
restored object sequence and ids are identical. I could not name the vector and
did not guess. It matters only because the harness's `dump` column is TEXT, so
this residue class can flip a dump verdict with no semantic change.

**R4 — the same raw-`SourceLocation` comparator appears in TEN other sort sites**
and each is a latent copy of the bug §4 fixes, wherever the two keys can land in
different buffers: `src/ModuleEmit.cpp:2216, 2551, 10352, 11896, 17193`,
`src/ParamEmit.cpp:19314`, `src/StmtEmit.cpp:2752`, `src/TaskFuncEmit.cpp:5016`,
`src/UhdmExporter.cpp:1975, 2371`. Several sort by NAME (`pkgTdByName`,
`gtds`) and are safe; the ones keyed on a location are not. **Ranked ahead of R1
for cheapness**: each is a one-line change to `srcOrderLess`, but each needs its
own cross-buffer witness before it is touched — do not sweep them blind.

**R5 — `d->Typespecs()` at `src/UhdmExporter.cpp:4331` is `stable_sort`ed with a
comparator that is NOT a strict weak ordering** (it returns `false` for every
same-buffer pair, so "equivalent" is not transitive across buffers). It happens
to be deterministic for a given input, but it is UB by the standard's
requirements and it is one refactor away from becoming a second §4. Cheap to fix
with a total order (rank, then name).

**R7 — a THIRD Scoreboard draw (`cfe85c11`, §4.1) means the listing has at least
one more nondeterminism source than the comparator this pass fixed.** The patched
binary drew one value 6/6, so whatever it is, it is rarer than the one that is
gone; it is NOT proven absent. The instrument is right here: 6 reps of
`--filter '^Scoreboard$' --jobs 1` and `md5sum` the databases. Do this BEFORE
quoting any Scoreboard byte result.

**R6 — the four r10oth8 §0.1 figures for `class_typespec` are dump occurrences
and should be struck from the record**, along with its "pristine 319 / shipped
384" SeqDriver alias figures, which my object census puts at 361 / 426 on the
same binaries.

---

## 8. WHAT I DID NOT MEASURE

* Whether `drainClassNestedTdGroups54`'s +98 class_typespec aliases are CORRECT
  (golden 131 vs our 132 says roughly yes, but I did not check them
  span by span).
* The other 66 address-ordered iteration sites individually: §2 shows the
  address order does not reach the population, which covers them collectively,
  but a per-site proof is not here.
* Scoreboard beyond 3 reps, and the other UVM tests for run-to-run byte
  stability at all.
* R4's ten sites for actual cross-buffer witnesses.

---

## 9. THE MANIFEST

| file | what it is |
|---|---|
| `dtpop.cpp` | the POPULATION CENSUS as OBJECTS (`Serializer::AllObjects()`): `ALIAS`/`CTS`/`TOTAL`, and `--ids` prints the address-order iteration as SOURCE identities so two runs' orders diff with no address in the comparison. Build: `g++ -std=c++17 -O1 -I ~/.local/include -o /tmp/r10det1_dtpop dtpop.cpp -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj` |
| `dtcen.sh` | one binary → the census table for both sides. Prints the binary md5 AND the env on every run. `DTCEN_REP=<tag>` for reps. **PASS THE BINARY AS AN ABSOLUTE PATH** — the harness `cwd`s into the test dir and a relative path yields a bogus `SURELOG_FAIL` (it cost me one run). |
| `dtperturb.sh` | THE DECISIVE EXPERIMENT: one binary, N heap layouts, with the mandatory `ADDRPROOF` line and the `PAD-INERT` guard. |
| `dtalias.cpp` | alias carriers PER KIND, both sides — the instrument that answered §5 and §3. |
| `dtvec.cpp` | every typespec listing vector's ORDER, as a multiset of whole-vector sequences (no owner identity, see §2.1). |
| `dtlist.cpp` | the design-level `Typespecs()` order; reports `UNMEASURED` when the design has none (BuildUVMPkg has none — that is why §2.1 needed `dtvec`). |
| `dttf.cpp` | every task_func listing vector's ORDER — **the probe that named §4's bug**. |
| `dtinv.py` | the container inventory of §1: every pointer-keyed member container, and which are ITERATED, with file:line. Run from the repo root. |
| `instrument.patch` | the `R10DET1_PAD` / `R10DET1_ORDER` instrument, env-guarded, as a patch against `3500bc4`. **NOT LANDED and NOT production code** — apply it to a scratch worktree to re-run §2. Its pad and order dump are read by no emitter decision, and the binary it builds gives the same population as pristine (§0), which is the check that the instrument does not perturb what it measures. |

Worktrees, all built by me: `r10det1pris` (P), `r10det1i` (I), `r10det1rev` (R),
`r10det1ir` (IR), `r10det1h8s` (S), `r10det1h8r` (S−), `r10det1h7` (Z),
`r10det1fix` (the shipped law).
