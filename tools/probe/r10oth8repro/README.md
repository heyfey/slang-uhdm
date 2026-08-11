# r10oth8 — `vpiSigned` on an `array_var`: ONE law, THREE call sites, TWO extra defects found

**Result, up front: SVSwitch did NOT convert. It stays `CMP_NOTEQUAL` in both
modes.** What moved:

* **cmp lines 132 → 18**, both modes (a HEAD-DEPTH measure).
* **dump distance 2697 → 2695 true content lines** (a DISTANCE measure; `sed 1d`
  on both dumps, `diff -u`'s own `---`/`+++` header excluded). Two lines — the
  moved field, exactly as a MOVE should read.
* **the head moved off the `array_var` onto the `byte_typespec` of the SAME
  declaration**: golden `byte_typespec , id:3771, 23:6-23:10`. ~~ours carries
  **TWO** objects at that span (`id:3771` and `id:1512`) where golden has ONE …
  an object-SHARING residue~~ — **REFUTED at integration (§0 F2): both sides mint
  FOUR `byte_typespec` spans, each printed twice. It is a FIELD + PARENT residue
  on ONE span** — golden's `23:6` carries `vpiParent` → `byte_var` and
  `vpiSigned:1`, ours carries neither, while the plain scalar `byte fcs;` one line
  below gets both from us. Ranked **R1** below, re-characterised, with the fix
  located.
* **the per-field census on SVSwitch, which is what shows the law working**:
  `array_var` objects carrying `vpiSigned` on THEMSELVES **0 → 1** (golden 1),
  and objects whose NESTED element var carries it **1 → 0** (golden 0).
* **ONE LAW, and it needed a REFUTATION of the brief's own model plus TWO
  previously-unknown defects at the two sites the brief called the correct
  siblings.** Measured on **122 arm cells** across 9 arms, both sides listed at
  OWN CHILD DEPTH: differing cells **54 → 7**, and **all 7 survivors are cells
  where one side emits no object at all** — of the 115 cells where both sides
  emit the `array_var`, **115 agree**.
* **Corpus reach: ZERO rows changed status or dump on either corpus** (731 and
  1588 committed baseline rows, whole-row diff). **Byte verifier: 0 movers on
  uhdm2rtlil (679/679), 9 movers on surelog (953/953)** — 8 of the 9 are
  `ONLY-VPISIGNED`, the 9th is the known-nondeterministic `Scoreboard/default`,
  re-proved flaky on BOTH binaries here (§6).
* **ZERO canary rows moved**, counted as ROWS: `canaries.sh` compared **52**
  surelog + **8** uhdm2rtlil rows and `ctcan2.sh` a further **58** + **1**, all
  `changed=0 absent=0`.

Base commit `8d4d6ed`, branch `auto5h`. Pristine binary md5
`2e27ef16b664eca1e5bdbfaa2ce5c365`, patched `fc3c008b32b2416b595ceaee1b1ee216`.
**AS SHIPPED the binary is `51bb84bca8a60e0e0b886a615a761322`** — the patched
build plus the master's F1 fix (§0).
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script.

---

## 0. MASTER'S INTEGRATION ADDENDUM — what changed between the verified patch and what landed

The verifier's verdict was **PARTIAL — landable**, with **one newly-introduced
over-fire (F1)** and eight write-up/instrument corrections (F2–F9). **F1 was a
behavioural defect, so it was FIXED BEFORE LANDING rather than recorded as
residue** — this pass exists to stop a typedef being pierced, and F1 was the same
piercing through a packed wrapper. Everything else is recorded in place, at the
claim, not appended at the end where a reader can miss it.

| # | what the document said | status |
|---|---|---|
| **F1** | clause (b) accepts `PackedArrayType` flatly | **CODE FIXED** by the master; clause (b) now descends the wrapper and requires the ultimate base to be `PredefinedIntegerType`/`ScalarType`. New arm `v1_pkarrtd.sv` (verifier-authored) is in this directory and wired into `ct8all.sh`; 6 cells, differing 0. §1 |
| **F2** | §8 R1: "golden ONE `byte_typespec`, ours TWO" — object sharing | **REFUTED, twice independently** (verifier `--stats` 4/4; master by span 4/4). R1 re-characterised as a **field+parent residue on ONE span**. §8 |
| **F3** | `ct8census.sh`'s "array_var objects" column | **RELABELLED** — it counts dump-occurrence keys with indentation attached, inflating ~2.6–2.8×. True objects added beside it. §6.1 |
| **F4** | "39 `+vpiSigned` / 51 `-vpiSigned`" over 9 databases | **CORRECTED to +70/−91** (39/51 was default-mode-minus-SVSwitch). §4 |
| **F5** | "the sum matches `ct8census.sh`'s 25→12" | **CORRECTED** — 33→20; only the delta agrees. §7 |
| **F6** | Scoreboard `content=193`, 170 non-`vpiSigned` | **NOT QUOTABLE** — a draw from the flaky distribution §6 itself proves; verifier drew 115/92. §6 |
| **F7** | three `isSigned()` call sites | **A FOURTH EXISTS**, unlisted: `src/TypeEmit.cpp:14954`, `ln->VpiSigned(true)` on the element `logic_net` of an `array_net`, reached through the same typedef-piercing resolution. Master confirmed it in the shipped tree. Recorded as **R0** in §8 — NOT fixed, because at NET scope golden's placement is genuinely different (arm a6 `g03`) and unmeasured. |
| **F8** | `ct8reach.sh`'s counts are "UPPER BOUNDS" | **Qualified** — `RE_ADD` omits `bit`/`logic` "because they are unsigned", but `bit signed x[]` / `logic signed x[]` / `reg signed x[]` are signed and the law fires on them (arms `f01`–`f03`, `g01`/`g02`, `h05`, `d07`/`e07`). Measured omission **8 declarations**, so ADD is not purely an upper bound. §4 |
| **F9** | small citations | "three lines above `VpiRandType(1)`" is **two**; R3's witnesses are `Environemnt.sv:17`/`:20`, **not 16/19**; the §9 manifest omits `ctflake.sh`; §3's a5 row `06` puts `d06`/`e06` in the class columns. Fixed at each site. |

**One refutation of the verifier, for symmetry:** its **R-5** ("the brief's 479 is
REFUTED") is overstated — 728 and 479 come from differently-scoped regexes, so
they are two instruments measuring different things, not a refutation. The
verifier said so itself; §4 keeps both numbers with their scopes named.

**BYTE STATE OF THE SHIPPED BINARY vs THE VERIFIED ONE (measured, not assumed).**
`byteverify.sh` shipped-vs-patched: **uhdm2rtlil 0 movers / 679**;
**surelog 7 movers / 953**, all four UVM tests. The 7 are **NOT `vpiSigned`** —
`BuildUVMPkg`'s dump diff between the two binaries carries **0 changed
`vpiSigned` lines** out of 1020 content lines; what moves is `class_typespec`
spans and `int_typespec`↔`string_typespec` at MACRO-BUFFER coordinates
(`line:13774`, `line:15203`), i.e. the campaign's known
macro-buffer/SourceLocation instability. Each of the three binaries is
**deterministic within itself** (`ctflake.sh`, 3 reps each: pristine
`3b5fd37288e7`, patched `80c8ab05ec28`, shipped `cdb85b3ec9cc`) and they draw
three different values — a per-binary draw, not a per-run one, and consistent
with an allocation-order-dependent iteration. **No row moved on either corpus and
no dump verdict changed**; the four tests were and stay `CMP_NOTEQUAL`.

### 0.1 A CAMPAIGN-LEVEL FINDING THIS INTEGRATION FORCED OUT: the ALIAS/TYPESPEC POPULATION IS BUILD-DEPENDENT

Chasing those 7 movers produced something worth more than the pass's own law, and
it is established **by elimination, with the alternative closed**:

* `arraySignedWritten8`'s return value feeds **nothing but `VpiSigned(true)`** —
  all three call sites, checked in the shipped tree (`grep -n leafSigned
  src/TypeEmit.cpp` → declared 14152, used 14158, and nowhere else).
* The **`vpiSigned` changed-line SETS are byte-identical** between the verified
  binary and the shipped one on both big tests (BuildUVMPkg `9+/12−`, SeqDriver
  `10+/13−`, `diff`-of-sorted-sets empty). So the F1 fix is a **semantic no-op**
  on them.
* Yet the same two databases move in a population the pass never touched:

| test | metric | GOLDEN | pristine | patched (verified) | **shipped** |
|---|---|---|---|---|---|
| BuildUVMPkg | `vpiTypedefAlias` | 1069 | 239 | 239 | **337** |
| BuildUVMPkg | `class_typespec` | 12671 | 12948 | 12948 | **13144** |
| SeqDriver | `vpiTypedefAlias` | 1709 | 319 | 319 | **384** |
| SeqDriver | `class_typespec` | 21168 | 18521 | 18521 | **18651** |

**+98 and +65 aliases and +196 and +130 `class_typespec` objects out of a
semantically-null edit.** Direction is mixed: alias counts move TOWARD golden,
`class_typespec` counts move FURTHER PAST it (we already overshot on
BuildUVMPkg). Each binary is deterministic across reps, and `ctflake.sh` uses
`--jobs 1` while the sweep uses `--jobs 2` and they agree, so this is **not**
parallel-parse flake.

**CONSEQUENCE — read this before quoting any UVM alias number.** The alias/base-pick
machinery from passes 50 and 54 (`pkgClassTd9`, the name-order base pick, the
`typedefTs`/`pkgTopTypedefTs` tables) is **order-dependent on something that moves
with the binary's layout**, so a UVM alias census is a property of the BUILD, not
only of the source. Pass 50's "alias counts now EXACTLY matching golden" and any
figure like `89/89` must be re-measured on the binary being judged, and two agents
in two worktrees can measure the same source and honestly disagree. Ranked next
after R1 as its own investigation: **find the container whose iteration order this
rides on** (a pointer- or address-keyed map in the alias path is the first
suspect), because until it is pinned, every UVM measurement in this campaign
carries an unquantified build term. The instrument to reuse is right here:
`ctflake.sh` for per-binary determinism, and the four-row table above for the
population.

**Why the pass still landed:** ~~the churn is not caused by the fix (proved
above), it is caused by *changing the binary at all*~~ — see the correction
immediately below; the operative reason is that the churn is not SEMANTIC (the
`vpiSigned` sets are identical), no row or dump verdict moved, and declining to
fix a known typedef-piercing over-fire in order to preserve one particular draw of
an unstable ordering would be preserving the artefact instead of the law. All five
gates are green on the shipped binary.

### 0.2 CORRECTION TO 0.1, ONE PASS LATER — "any binary change flips it" IS REFUTED, and the MECHANISM IS NAMED

**REFUTED by r10oth9** (the very next pass, `tools/probe/r10oth9repro/`): it
changed the binary too — `51bb84bc…` → `6c33528b…`, and three independent builds
in three different trees agreed on that md5 bit-for-bit — and its 9 surelog byte
movers carry **ZERO changed `class_typespec` and `vpiTypedefAlias` lines**, all 9
attributable to its own law. So *changing the binary* is NOT sufficient. What
r10oth8's F1 hunk did specifically is: it **stops calling `isSigned()`** on some
written types (the descent returns false before clause (c)), and in slang that
call can force lazy type resolution, which ALLOCATES. Different allocation ⇒
different addresses.

**Why addresses reach the output — the structural finding, and it makes this a
FINDABLE BUG rather than a mood:** the exporter keys several typespec/alias tables
on POINTERS and then ITERATES them.

| table | declaration | iterated at |
|---|---|---|
| `typedefTs` | `std::map<const slang::ast::Symbol*, UHDM::typespec*>`, `include/UhdmExporter.h:2595` | `src/TypeEmit.cpp:7238`, `:7363`; `src/TaskFuncEmit.cpp:2768`, `:2797`, `:3020`, `:3141` |
| `pkgTopTypedefTs` | `std::map<const void*, UHDM::typespec*>`, `include/UhdmExporter.h:3483` | `src/TypeEmit.cpp:7241`, `:7365`, `:7398` |
| `bareScalarTdCopy` | `std::map<const UHDM::typespec*, UHDM::typespec*>`, `include/UhdmExporter.h:505` | `src/TypeEmit.cpp:7625` |

`std::map` over a pointer key iterates in **ADDRESS order**. Those loops feed
`listingTs` and `aliasOfAlias` — themselves `std::set<const typespec*>`, address-ordered
again — and the campaign's own FIRST-WINS / LAST-LISTER policies then make the
WINNER depend on that order. Address order changes ⇒ a different object wins ⇒ a
different alias/typespec population. That closes the loop from "my 20-line
predicate edit" to "+98 aliases on BuildUVMPkg" without any semantic change.

**RANKED FOLLOW-UP, now concrete:** give those tables a stable iteration order —
key on a source identity (file/line/col/name) or carry an insertion-ordered vector
beside the map — and re-measure. Until then every UVM alias census carries an
unquantified build term. Do it AFTER the in-flight UVM pass lands: it is the same
region.

**One more correction, from r10oth9's verifier (its F2):** "each binary is
deterministic across reps" holds for BuildUVMPkg and SeqDriver (6/6 identical for
me) but **NOT for Scoreboard**, which is nondeterministic on *every* binary
(5/5 identical on one pristine run, 3-of-5 distinct on a patched one, 2 distinct
over 12 further pristine reps). State the test name with the determinism claim;
`ctflake.sh` is the instrument either way.

---

## 1. THE LAW

### § arrayVarSignedWritten8

**NAME AS IN THE CODE COMMENT:** `§ arrayVarSignedWritten8`, at four comment
sites — the predicate itself (`src/UhdmExporter.cpp`, grep
`arrayVarSignedWritten8 — the ONE predicate`), the class-property ADD half
(grep `the ADD half`, in `emitClassDefn`'s dynamic/queue/assoc block), the
class-property SUPPRESS half (grep `the SUPPRESS half`, same block), and the two
module-scope ADD halves in `src/TypeEmit.cpp` (`emitDynArrayVar` and
`emitArrayVar`; grep `the ADD half at the MODULE-SCOPE`).

**THE PREDICATE, exactly:** an `array_var` carries `vpiSigned:1` iff

* **(a)** the declaration's own type is **not itself a typedef NAME**
  (`declaredWhole.kind != SymbolKind::TypeAlias`), **and**
* **(b)** the element type **as written** is of kind `PredefinedIntegerType`
  (an integer atom), `ScalarType` (`bit`/`logic`/`reg`) or `PackedArrayType`
  (a packed vector of those) — never an enum, struct, union, class handle,
  string, real or typedef name, **and**
* **(c)** that written type `isSigned()`.

> **MASTER'S CORRECTION AT INTEGRATION — clause (b) as written above is WRONG,
> and the code in the tree does NOT match it.** A flat `PackedArrayType`
> whitelist **defeats clause (a)**: a written `b_t [3:0]` is a `PackedArrayType`
> whose own `elementType` is the `TypeAlias`, and `isSigned()` resolves straight
> through it, so the predicate pierced exactly the typedef the law excludes. The
> verifier found this (its finding **F1**) and built the arm; I fixed the code
> before landing. **The clause as SHIPPED descends the packed wrapper and
> requires the ULTIMATE packed base to be `PredefinedIntegerType` or
> `ScalarType`** — `PackedArrayType` is a transparent wrapper, not an accepted
> kind (grep `Do NOT canonicalise while walking`). Measured by me on the
> verifier's arm `v1_pkarrtd.sv`, now in this directory and wired into
> `ct8all.sh`, with the F1-fixed binary `51bb84bca8a60e0e0b886a615a761322`:
>
> | cell | golden | ours pristine | patched-only (F1 live) | **SHIPPED** |
> |---|---|---|---|---|
> | `v01`/`w01` `b_t [3:0] x[]` | `-` | `-` | **`1` WRONG** | **`-` EQ** |
> | `v02`/`w02` `bit signed [7:0][3:0] x[]` | `1` | `-` | `1` | **`1` EQ** |
> | `v03`/`w03` `se_t [1:0] x[]` (signed-enum td) | `-` | `-` | **`1` WRONG** | **`-` EQ** |
>
> `v02`/`w02` is the positive control for the descent, and all six cells read
> `differing=0`. The original 9 arms re-measured on the shipped binary are
> **unchanged: 122 cells, differing 7, every survivor a cell where one side
> emits no object** — so the fix closes the hole at zero cost to the law. Grand
> total for the pass: **128 cells, 7 differing, 0 field disagreements.**

and its `vpiReg` element var carries `vpiSigned` **never** — `VpiSigned(false)`
unconditionally, at class-property and module/package-variable scope.

**DIRECTION.** At the class-property site it is a **MOVE**: ADD on the
`array_var` **and** SUPPRESS on the element. At the two module-scope sites it is
a **NARROWING** of a field that was already being added: the field stays on the
cells where golden has it and is REMOVED from the typedef'd / enum / struct
cells where golden does not.

**HOW EACH CLAUSE WAS PROVED NECESSARY** — each row is a cell where dropping the
clause makes us disagree with golden:

| clause | necessary because | witness cells (golden vs ours-pristine) |
|---|---|---|
| (a) declaration not a typedef name | `typedef byte barr_t[]; barr_t x;` gets NO `vpiSigned`, and golden gives that shape no `vpiArrayType` either | a5 `d04`/`d05` (class) and `e04`/`e05` (module): golden `-`, ours `1` at module scope |
| (b) kind whitelist | an inline `struct packed signed { byte a; }` IS signed and golden still gives the array nothing; an inline anonymous `enum` likewise. "written AND signed" without the kind list over-fires on both | a5 `d09`/`e09` (signed packed struct) and `d01`/`e01` (anon enum): golden `-`, ours `1` at module scope |
| (b) "as WRITTEN", i.e. TypeAlias excluded | `typedef byte b_t; b_t x[];` gets NO `vpiSigned` — this is the clause that REFUTED the brief's model | a3 `c01`,`c03`,`c04`,`c05`,`c06`; a4 same cells; a7 `h02`,`h03`; a8 `k01`,`k02`,`k03`,`m01`,`m02`,`m03`,`m06` |
| (c) signedness | `byte unsigned`, `bit`, `logic`, `bit [7:0]`, `int unsigned`, `time`, `string`, `real` all get nothing | a1 `a03`,`a04`,`a05`,`a14`,`a15`,`a21`,`a22`; a6 `f04`,`f05` |
| ADD half on the ARRAY | golden's `array_var` carries the field and its element does not | a1 `a01` (the witness), and every `1` cell in every table |
| SUPPRESS half on the ELEMENT | golden's `vpiReg` var carries `vpiSigned` in **0 of the 118** class/module cells | a1 `a01`..`a20`, a3 `c01`..`c11`, a8 `k*`/`m*` |
| the law is SCOPE-BOUND | at SUBROUTINE-LOCAL scope golden does the OPPOSITE — element signed, array bare | a9 `n01`,`n02`,`n03` (golden nested `byte=1`/`int=1`, own `-`) |

**WITNESSES.** `third_party/tests/SVSwitch/Packet.sv:23`, `rand byte data[];` —
the head at base `8d4d6ed`, reproduced standalone as arm a9 cell `p01`. Plus the
122 arm cells of §3.

---

## 2. EVERY REFUTATION, INCLUDING TWO OF THE BRIEF'S OWN CLAIMS

**R-1. The brief's central model — "signedness rides the array, keyed on the
element type" — is TRUE but INCOMPLETE, and implementing it as stated would have
shipped an over-fire.** The brief describes the fix as routing the class arm
through the module-scope rule. The module-scope rule keys on
`leaf->isSigned()`, which resolves THROUGH a typedef. Golden does not: a
`typedef byte b_t; b_t x[];` element gets **no** `vpiSigned` anywhere. Had the
class arm been routed through the existing predicate unchanged, every UVM class
property typed by a package typedef (`uvm_reg_addr_t`, `uvm_bitstream_t`, …)
would have gained a field golden does not have. Refuted by arm a3 (class) and
confirmed as not-a-$unit-artefact by arm a8 (package typedef, bare-imported AND
`pkg::`-qualified).

**R-2. The brief's claim that it "did not find" `av->VpiSigned(true)` in the
module-scope arm is wrong: the call is there.** `src/TypeEmit.cpp`, in
`emitDynArrayVar`, TWO lines above `av->VpiRandType(1)` (pristine 14453/14454/14455 — verifier F9; "three" was wrong) — it read
`if (leaf->isSigned()) av->VpiSigned(true);`. The brief's window simply missed
it. The module-scope array_var did NOT get its signedness "from elsewhere".

**R-3. The brief's question "is the module-scope sibling already correct?" has
the answer NO, and that is the SECOND FINDING it asked for.** Arm a2 — the
brief's own shape, `byte x[]` and friends at module scope — is 22/22 EQ, which is
why the defect was invisible until arms a4/a5/a8 added typedef, enum and struct
cells. `emitDynArrayVar` over-fired on **13** measured cells: a4
`c01`,`c03`,`c04`,`c05`,`c06`; a5 `e01`,`e03`,`e04`,`e05`,`e09`; a8
`m01`,`m02`,`m03`.

**R-4. A THIRD site has the same defect, and it has the LARGEST population:
`UhdmExporter::emitArrayVar`, the module-scope FIXED-size unpacked array.** Arm
a7 `h02` (`typedef byte b_t; b_t x[4];`) and `h03`, plus a8 `m06`
(`tp::pb_t x[4];`): golden `-`, ours `1`. This was not in the brief at all. It is
fixed here by the same predicate, because leaving two of three call sites wrong
while citing one shared law would have been a fiction.

**R-5. The brief's reach figure is REFUTED, in both its total and its
decomposition.** The brief carries "479 signed-element dynamic/queue/assoc
declarations across both corpora (155 queue, 304 dynamic, 20 assoc), with only 3
in uvm-1.2 itself", flagged UNVERIFIED. Re-measured from scratch by
`ct8reach.sh` (§4): the ADD population is **728** across the two tests roots and
**uvm-1.2 alone has 83**, not 3. The queue/dynamic/assoc decomposition is not
reproducible from any regex here and is therefore **not repeated anywhere in this
write-up** — the brief's number is superseded, not adjusted.

**R-6. My own first instrument was wrong in the way the brief warned about, and
the fix is in the shipped code.** `ct8grid.py`'s first draft raised
`FileNotFoundError` when one side had produced no database, printing a Python
traceback where the arm table belonged. A traceback is not a reading; it now
prints `UNMEASURED`. The negative control is in §7.

---

## 3. THE ARM GRID — 122 CELLS, BOTH SIDES, OWN CHILD DEPTH

Nine arms. Every table below is the `vpiSigned` column produced by
`ct8grid.py <g.dump> <o.dump> vpiSigned <prefix>`, which prints FOUR cells per
row: the field on the `array_var`'s OWN depth and on its NESTED element, for
golden and for ours. `-` = the field is ABSENT; `UNMEASURED` = that side emits no
`array_var` for the declaration at all, which is a louder and different reading.

**Why own-depth matters, and it is this campaign's own error, made twice.** The
r10oth8 brief records its author's first extraction walking everything under the
`array_var` and concluding both sides carried `vpiSigned:1` "in a different
order". They do not — golden's is on the array, ours was on the element. A
flattening instrument cannot see a MOVE; it sees a reorder. `ct8fields.py`
therefore reports own-depth fields and nested fields in separate columns, and its
`--defn` mode drops the bare back-reference occurrences uhdm-dump prints wherever
an object is REFERENCED (the same trap in its other direction: a reference
occurrence read as the object says every field is missing).

Totals: **differing cells 54 → 7**; every survivor is an `UNMEASURED` cell.

### arm a1 — `a1_class.sv`, CLASS PROPERTIES, 22 cells (16 → 4 differing)

| cell | declaration | G.own | O.own pri → fin | G.nested | O.nested pri → fin |
|---|---|---|---|---|---|
| a01 | `rand byte x[]` — **THE WITNESS** | 1 | - → **1** | - | byte=1 → **-** |
| a02 | `byte x[]` (no `rand`) | 1 | - → **1** | - | byte=1 → **-** |
| a03 | `rand byte unsigned x[]` | - | - | - | - |
| a04 | `rand bit x[]` | - | - | - | - |
| a05 | `rand logic x[]` | - | - | - | - |
| a06 | `rand int x[]` | 1 | - → **1** | - | int=1 → **-** |
| a07 | `rand shortint x[]` | 1 | - → **1** | - | short_int=1 → **-** |
| a08 | `rand longint x[]` | 1 | - → **1** | - | long_int=1 → **-** |
| a09 | `rand integer x[]` | 1 | - → **1** | - | integer=1 → **-** |
| a10 | `rand byte x[$]` (queue) | 1 | - → **1** | - | byte=1 → **-** |
| a11 | `rand byte x[string]` (assoc) | 1 | - → **1** | - | byte=1 → **-** |
| a12 | `rand byte x[4]` (fixed) | 1 | UNMEASURED | - | UNMEASURED |
| a13 | `rand byte signed x[]` | 1 | - → **1** | - | byte=1 → **-** |
| a14 | `rand int unsigned x[]` | - | - | - | - |
| a15 | `rand bit [7:0] x[]` | - | - | - | - |
| a16 | `rand bit signed [7:0] x[]` | 1 | - → **1** | - | - |
| a17 | `rand byte x[4][]` | 1 | UNMEASURED | - | UNMEASURED |
| a18 | `rand byte x[][4]` | 1 | UNMEASURED | - | UNMEASURED |
| a19 | `rand int x[$]` | 1 | - → **1** | - | int=1 → **-** |
| a20 | `rand int x[string]` | 1 | - → **1** | - | int=1 → **-** |
| a21 | `string x[]` | - | - | - | - |
| a22 | `real x[]` | - | UNMEASURED | - | UNMEASURED |

`a12`/`a17`/`a18`/`a22` are UNMEASURED on our side both before and after: we
emit **nothing** for a fixed-size class-property array or a `real` element
(`class property type: FixedSizeUnpackedArrayType` / `class array property
element`). Residue R3/R4 below. **`rand` is NOT the gate** — a01 and a02 agree.

### arm a2 — `a2_module.sv`, the MODULE twin of a1, 22 cells (0 → 0 differing)

Every cell EQ before AND after. **This is the arm the brief pointed at, and on
its own it says the module site is correct** — see §2 R-3 for why that reading is
false. Unchanged by the patch, which is the POSITIVE control for the narrowing:
tightening the predicate did not disturb a single written-keyword cell.

### arm a3 — `a3_elemkind.sv`, CLASS, element KINDS, 11 cells (5 → 0)

| cell | element as written | G.own | O.own pri → fin | G.nested | O.nested pri → fin |
|---|---|---|---|---|---|
| c01 | `b_t` = `typedef byte` | **-** | - | - | byte=1 → **-** |
| c02 | `u8_t` = `typedef bit [7:0]` | - | - | - | - |
| c03 | `s16_t` = `typedef bit signed [15:0]` | **-** | - | - | - |
| c04 | `i_t` = `typedef int`, queue | **-** | - | - | int=1 → **-** |
| c05 | `b_t`, assoc `[string]` | **-** | - | - | byte=1 → **-** |
| c06 | `e_t` = `typedef enum` | - | - | - | - |
| c07 | `sp_t` = `typedef struct packed` | - | - | - | - |
| c08 | `logic signed [3:0]` | 1 | - → **1** | - | - |
| c09 | `byte`, assoc indexed by `e_t` | 1 | - → **1** | - | byte=1 → **-** |
| c10 | a class handle | - | - | - | - |
| c11 | `string`, queue | - | - | - | - |

**c01 is the cell that refuted the brief's model**: a typedef of `byte` is
signed, and golden gives the array_var nothing.

### arm a4 — `a4_modelem.sv`, the MODULE twin of a3, 11 cells (5 → 0)

| cell | G.own | O.own pri → fin |
|---|---|---|
| c01 `b_t x[]` | - | **1 → -** |
| c02 `u8_t x[]` | - | - |
| c03 `s16_t x[]` | - | **1 → -** |
| c04 `i_t x[$]` | - | **1 → -** |
| c05 `b_t x[string]` | - | **1 → -** |
| c06 `e_t x[]` | - | **1 → -** |
| c07 `sp_t x[]` | - | - |
| c08 `logic signed [3:0] x[]` | 1 | 1 |
| c09 `byte x[e_t]` | 1 | 1 |
| c10 class handle | - | - |
| c11 `string x[$]` | - | - |
| *(nested column: `-` on both sides in all 11 cells, before and after)* | | |

**This is the arm that found the SECOND DEFECT.** Five module-scope cells were
over-firing.

### arm a5 — `a5_written.sv`, the BOUNDARY arm, 20 cells (11 → 1)

Class half `d*` / module half `e*`, one Surelog run so the two scopes can never
come from different golden databases.

| cell | declaration | G.own | O.own pri → fin (class `d`) | G.own | O.own pri → fin (module `e`) |
|---|---|---|---|---|---|
| `d01_dyn_anonenum / e01_dyn_anonenum` | inline anonymous `enum {A,B} x[]` | - | - | - | **1 → -** |
| `d02_dyn_anonstruct / e02_dyn_anonstruct` | inline anonymous `struct packed x[]` | - | - | - | - |
| `d03_dyn_chain / e03_dyn_chain` | `b2_t` (typedef CHAIN of `byte`) | - | (nested byte=1 → **-**) | - | **1 → -** |
| `d04_arrtd / e04_arrtd` | `barr_t x` (the ARRAY typedef'd) | - | (nested byte=1 → **-**) | - | **1 → -** |
| `d05_qtd / e05_qtd` | `bq_t x` (queue typedef'd) | - | (nested byte=1 → **-**) | - | **1 → -** |
| `d06_dyn_localtd / e06_dyn_localtd` | class-LOCAL `typedef byte` / plain `byte` | - / 1 | (nested byte=1 → **-**) / 1 | | |
| `d07_dyn_pk2s / e07_dyn_pk2s` | `bit signed [7:0][3:0] x[]` | 1 | - → **1** | 1 | 1 |
| `d08_dyn_pk2u / e08_dyn_pk2u` | `bit [7:0][3:0] x[]` | - | - | - | - |
| `d09_dyn_spsigned / e09_dyn_spsigned` | `struct packed signed {byte a;} x[]` | **-** | - | **-** | **1 → -** |
| `d10_dyn_shortreal / e10_dyn_shortreal` | `shortreal x[]` | - | UNMEASURED | - | - |

Cells `04`/`05` also carry a SEPARATE residue: golden's object has **no
`vpiArrayType` at all** where ours says 2 / 4 (R5 below). Cell `06`'s class and
module halves are deliberately DIFFERENT declarations — a class-local typedef has
no module equivalent — and the module half is the written-keyword control.

### arm a6 — `a6_kindgate.sv`, the KIND WHITELIST, 14 cells (6 → 2)

| cell | declaration | G.own | O.own pri → fin (class `f`) | G.own | O.own pri → fin (module `g`) |
|---|---|---|---|---|---|
| `f01_dyn_bitsigned / g01_dyn_bitsigned` | `bit signed x[]` | 1 | - → **1** | 1 | 1 |
| `f02_dyn_logicsigned / g02_dyn_logicsigned` | `logic signed x[]` | 1 | - → **1** | 1 | 1 |
| `f03_dyn_regsigned / g03_dyn_regsigned` | `reg signed x[]` | 1 | - → **1** | UNMEASURED | 1 |
| `f04_dyn_time / g04_dyn_time` | `time x[]` | - | - | UNMEASURED | - |
| `f05_dyn_bit / g05_dyn_bit` | `bit x[]` | - | - | - | - |
| `f06_q2_byte / g06_q2_byte` | `byte x[$:7]` (BOUNDED queue) | 1 | - → **1** | 1 | 1 |
| `f07_dyn_unpstruct / g07_dyn_unpstruct` | inline UNPACKED `struct x[]` | - | - | - | - |

`g03`/`g04` are UNMEASURED on GOLDEN's side: at module scope Surelog compiles
`reg signed x[]` and `time x[]` to `logic_net` + `array_net`, not an `array_var`
(R6 below). `f06`/`g06` also carry an independent `vpiArrayType` disagreement
(golden 1, ours 4 — R7); the `vpiSigned` verdict is EQ and the arm table's
verdict column covers `vpiSigned` only, which is why the aType columns are
printed but not judged.

### arm a7 — `a7_fixedtd.sv`, the FIXED-SIZE module site, 5 cells (2 → 0)

| cell | declaration | G.own | O.own pri → fin |
|---|---|---|---|
| h01 | `byte x[4]` | 1 | 1 (POSITIVE control: unmoved) |
| h02 | `b_t x[4]` | - | **1 → -** |
| h03 | `i_t x[2][3]` | - | **1 → -** |
| h04 | `u8_t x[4]` | - | - |
| h05 | `bit signed [7:0] x[4]` | 1 | 1 (POSITIVE control: unmoved) |

**This is the arm that found the THIRD site.**

### arm a8 — `a8_pkgtd.sv`, the PACKAGE-TYPEDEF distinguisher, 12 cells (8 → 0)

The single most load-bearing arm: every other typedef cell uses a `$unit`
typedef, and UVM spells every element type through a PACKAGE typedef.

| cell | declaration | G.own | O.own pri → fin |
|---|---|---|---|
| k01 | class, `pb_t x[]` (wildcard-imported) | - | - (nested byte=1 → **-**) |
| k02 | class, `tp::pb_t x[]` (qualified) | - | - (nested byte=1 → **-**) |
| k03 | class, `tp::pi_t x[$]` | - | - (nested int=1 → **-**) |
| k04 | class, `tp::pu8_t x[]` | - | - |
| k05 | class, `byte x[]` | 1 | - → **1** |
| m01 | module, `pb_t x[]` | - | **1 → -** |
| m02 | module, `tp::pb_t x[]` | - | **1 → -** |
| m03 | module, `tp::pi_t x[$]` | - | **1 → -** |
| m04 | module, `tp::pu8_t x[]` | - | - |
| m05 | module, `byte x[]` | 1 | 1 |
| m06 | module, `tp::pb_t x[4]` (FIXED) | - | **1 → -** |
| m07 | module, `byte x[4]` (FIXED) | 1 | 1 |

Neither spelling nor package scope changes golden's answer. The model holds.

### arm a9 — `a9_scope.sv`, the SCOPE NEGATIVE CONTROL + the witness, 5 cells (1 → 0)

| cell | declaration | G.own | O.own pri → fin | G.nested | O.nested pri → fin |
|---|---|---|---|---|---|
| p01 | `rand byte data[]` in a class — **the SVSwitch witness, standalone** | 1 | - → **1** | - | - |
| n01 | `byte x[]`, SUBROUTINE local | - | - | **byte=1** | **byte=1** |
| n02 | `byte x[$]`, SUBROUTINE local | - | - | **byte=1** | **byte=1** |
| n03 | `int x[]`, SUBROUTINE local | - | - | **int=1** | **int=1** |
| n04 | `byte x[]`, STATEMENT-BLOCK local | - | - | - | - |

**`n01`..`n03` are the negative control for the whole law**: at subroutine-local
scope golden puts `vpiSigned` on the ELEMENT and nothing on the array — the exact
opposite placement. `src/TaskFuncEmit.cpp` already implements that
(`if (qelem0->isSigned()) reg0->VpiSigned(true);`) and this pass deliberately
does not touch it. These four cells are byte-identical before and after, which is
the proof the law did not leak out of its scope.

---

## 4. CORPUS REACH, RE-MEASURED (the brief's 479 is superseded — §2 R-5)

`ct8reach.sh`. Two populations, and the split is the point: the law turns on the
part grep cannot resolve.

| root | ADD population (DECIDABLE: written signed integer keyword) | TD population (UNDECIDABLE: element is a NAME) |
|---|---|---|
| `Surelog/tests` | 301 | 480 |
| `Surelog/third_party/tests` | 406 | 1596 |
| `uhdm2rtlil/test` | 21 | 29 |
| **total (both corpora)** | **728** | **2105** |

The UVM LIBRARY ITSELF is under NEITHER tests root — the four UVM tests' `.sl`
files point at `Surelog/third_party/UVM/...` — so it is counted separately:

| library | ADD | TD |
|---|---|---|
| `1800.2-2017-1.0` | 71 | 916 |
| `uvm-1.2` | 83 | 815 |
| `uvm-1.1d` | 55 | 678 |
| `vmm-1.1.1a` | 22 | 446 |
| `ovm-2.1.2` | 19 | 91 |
| `svaunit` / `svaunit_cp` | 18 / 18 | 97 / 97 |
| `svunit_base` | 0 | 6 |

Both figures are UPPER BOUNDS (a match can be in a comment, a string or a
formal), both are decomposable per test, and the SVSwitch self-check asserts
`-eq 1` — `Packet.sv:23` and nothing else. **The corpus being 97 %+ equal and the
ADD population being 728 are consistent because the reachable-and-wrong subset is
small: the class-property ADD half only reaches CLASS properties, and the two
module-scope narrowings only reach declarations whose element is written as a
NAME that resolves to a signed type — a strict subset of the 2105 TD
population.** The EMPIRICAL reach — the only number that is not an upper bound —
is the byte verifier's: **5 tests, 9 databases out of 953 on surelog and 0 of 679
on uhdm2rtlil**, moving ~~**39 `+vpiSigned` and 51 `-vpiSigned` lines in
total**~~ **`+70` / `−91` `vpiSigned` lines over the 9 databases** (§6).
> **CORRECTION (verifier F4, and it contradicted §6 of this same document).**
> 39/51 is the tally for *default mode with SVSwitch excluded* — it silently drops
> the pass's own target and every `testflags` row. The 9-database tally is
> **+70/−91**; the 5 default-mode databases alone are +40/−52. So the honest reading of the two populations above is that they bound the
law's reach at 728 + 2105 written declarations while the reach that MOVED BYTES in
these two corpora is 9 databases: nearly all corpus array declarations either are
not class properties, or are elements whose written type is unsigned, or sit in
tests our side rejects before it ever gets there (286 `SLANG_REJECT` rows in
testflags alone).

---

## 5. THE FIVE GATES

| gate | result |
|---|---|
| 1. build | `Built target slang_uhdm`, waited for the LINK; md5 `2e27ef16…` → `fc3c008b…`, asserted BEFORE any sweep was launched and in a SEPARATE command |
| 2. goldens | **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| 3. uhdm2rtlil, testflags, `--jobs 2` | 731 rows: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, dump **496 match / 183 differ / 52 blank** — identical to the committed baseline; whole-row diff **0 differing ROWS** |
| 4. surelog, `--mode both`, `--jobs 2` | 1588 rows: default **467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL**, testflags **463 / 10 / 5 / 286 / 23 (+3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE)**; dump match **225 default / 165 testflags** — every figure identical to the committed baseline, so THE MATCH COUNTS DID NOT FALL; whole-row diff **0 differing ROWS** |
| 5. byte verifier, BOTH corpora | uhdm2rtlil **0 movers / 679**, surelog **9 movers / 953**, path sets IDENTICAL on both. Controls: `SELFCHECK` **678/679** flagged, `SELFCHECK1` **exactly 1** |

An extra determinism control fell out of the build discipline and is worth
recording: the base commit rebuilt in a SEPARATE directory
(`/tmp/r10oth8_base`) reproduced the pristine md5 `2e27ef16…` **exactly**, and
the comment-only rebuild of the patched tree reproduced `fc3c008b…` exactly. So
the pristine reference the byte verifier compares against is a genuine build of
`8d4d6ed` and not a stale artefact.

**`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` were never
rebuilt, edited or included.** Every fresh CSV lives under `/tmp/r10oth8_*`.

---

## 6. THE 9 SURELOG BYTE MOVERS, EACH ATTRIBUTED

`ct8movers.sh` diffs OUR pristine dump against OUR patched dump, so every line it
reports is a byte this pass moved. It also prints whether EVERY changed line is a
`|vpiSigned:` line.

| mover | dump content lines | `+vpiSigned` | `-vpiSigned` | verdict |
|---|---|---|---|---|
| `default/SVSwitch` | 2 | 1 | 1 | ONLY-VPISIGNED |
| `testflags/SVSwitch` | 2 | 1 | 1 | ONLY-VPISIGNED |
| `default/SimpleUVM` | 23 | 10 | 13 | ONLY-VPISIGNED |
| `testflags/SimpleUVM` | 23 | 10 | 13 | ONLY-VPISIGNED |
| `default/SeqDriver` | 23 | 10 | 13 | ONLY-VPISIGNED |
| `testflags/SeqDriver` | 23 | 10 | 13 | ONLY-VPISIGNED |
| `default/BuildUVMPkg` | 21 | 9 | 12 | ONLY-VPISIGNED |
| `testflags/BuildUVMPkg` | 21 | 9 | 12 | ONLY-VPISIGNED |
| `default/Scoreboard` | 193 | 10 | 13 | **MIXED (170 non-vpiSigned lines)** |

All nine tests are already `CMP_NOTEQUAL` (Scoreboard testflags is
`SLANG_REJECT`), so no PASS was ever at risk, and all nine ROWS are byte-identical
to the committed baseline.

**The Scoreboard MIXED reading is the known nondeterminism, and it is
re-measured here rather than asserted.** `ctflake.sh Scoreboard <pristine>
<patched> 4 default` — four reps per binary, each in its own workdir:

| binary | rep 1 | rep 2 | rep 3 | rep 4 |
|---|---|---|---|---|
| pristine `2e27ef16` | `366578ccc2db` | `3fbff3e1b5e7` | `3fbff3e1b5e7` | `366578ccc2db` |
| patched `fc3c008b` | `3298ba1835ab` | `3298ba1835ab` | `d7428bf23818` | `d7428bf23818` |

**Both binaries emit two different databases across four reps**, and the sweep
produced a third pristine md5 again (`8ca0ef094f0f`). The non-`vpiSigned`
lines are `+\_function:` / `+|vpiTaskFunc:` additions on `svunit_pkg::svunit_base`
methods — an ordering/inclusion flip, not a field this pass touches. Its 10/13
`vpiSigned` lines match the other movers exactly.

> **DO NOT QUOTE `193` / `170` AS NUMBERS (verifier F6).** The verifier's
> independent run of the same script on the same pair gave `content=115`,
> 92 non-`vpiSigned` — same class of line, same named methods, same 10/13
> `vpiSigned`. Both readings are draws from the flaky distribution this very
> section proves exists, so the *character* of the difference is the finding and
> the magnitude is not a measurement at all. The table row above therefore keeps
> its `193` only as the value THIS run drew.

### 6.1 THE CORPUS-SCALE PER-FIELD CENSUS — what the movers actually are

`ct8census.sh`, own depth, both sides. Identical in both modes for each test.

| test | `array_var` DUMP-OCCURRENCE KEYS (G / O) — **NOT objects**, see below | TRUE objects (G / O) | own `vpiSigned` G | own O pri → fin | nested-elem G | nested O pri → fin |
|---|---|---|---|---|---|---|
| SVSwitch | 12 / 8 | **5 / 3** | 1 | **0 → 1** | 0 | **1 → 0** |
| SimpleUVM | 1593 / 1592 | **573 / 570** | 10 | **0 → 10** *(EXACTLY golden)* | 7 | 22 → 9 |
| BuildUVMPkg | 1683 / 1673 | **641 / 640** | 9 | **0 → 9** *(EXACTLY golden)* | 9 | **21 → 9** *(EXACTLY golden)* |
| SeqDriver | 2268 / 2235 | **996 / 867** | 10 | **0 → 10** *(EXACTLY golden)* | 23 | 25 → 12 |

> **COLUMN RELABELLED (verifier F3) — and this is the campaign's objects-vs-dump-lines
> trap catching this pass in the one place it thought it had fixed it.**
> `ct8census.sh`'s first column keys on `hdr.split(', ')[0]` **with the indentation
> still attached**, so the same object counted once per depth it is printed at —
> inflating the count ~2.6–2.8×. `ct8nested.py` was fixed for this; `ct8census.sh`
> was not. The `vpiSigned` columns are unaffected (only definitional occurrences
> carry fields, and my own by-span reading of SVSwitch in §8 R1 confirms it), but
> the true-object column **understates nothing and widens SeqDriver's object gap
> from 33 to 129**.
>
> **THE SCRIPT IS NOW FIXED, not merely documented** (`ct8census.sh`, grep `THIS
> LINE WAS THE DEFECT`): the key is the header text after the `\_array_var:`
> marker — parenthesised name plus `line:`/`endln:` span — with indentation
> stripped. Re-run by the master on the SHIPPED binary, `default` mode:
>
> | test | keyed name+span headers G / O | own `vpiSigned` G / O | nested-elem G / O |
> |---|---|---|---|
> | SVSwitch | **5 / 3** *(= `--stats`)* | **1 / 1** | **0 / 0** |
> | SimpleUVM | 447 / 446 | **10 / 10** | 4 / 6 |
> | BuildUVMPkg | 520 / 519 | **9 / 9** | **5 / 5** |
> | SeqDriver | 635 / 631 | **10 / 10** | 17 / 9 |
>
> **The own-`vpiSigned` column is EXACTLY golden's on all four tests** — the
> law's headline, re-measured on the binary that shipped rather than carried from
> the implementer. Note the denominators still differ from `uhdm-dump --stats`
> (573/570, 641/640, 996/867 on the three UVM tests) because **the two
> instruments count different things by design**: `--stats` counts every
> `array_var` in the database, this key counts distinct name+span array_var
> HEADERS in the dump tree. On SVSwitch they coincide (5/3), on UVM they must not
> be read as rival measurements of one quantity. Quote `--stats` for objects.

**THE NESTED COLUMN MIXES TWO OPPOSITE LAWS AND MUST BE SPLIT.** Read as one
number, SeqDriver's `25 → 12` against a golden of `23` looks like a move AWAY from
golden. It is not: golden puts `vpiSigned` on the ELEMENT at subroutine-local
scope and on the ARRAY at class/member scope, so the column sums two populations
that golden treats oppositely. `ct8nested.py` splits it BY NAME:

| test | MEMBER (class-property / module-var) nested disagreements | LOCAL (subroutine/block) nested disagreements |
|---|---|---|
| SeqDriver | **19 → 6** | **14 → 14** |
| SimpleUVM | **15 → 2** | **3 → 3** |
| BuildUVMPkg | **13 → 1** | **2 → 2** |

Every member cell fixed was a `golden=False ours=True` class property
(`uvm_pkg::uvm_queue::queue`, `uvm_report_handler::severity_actions`,
`uvm_objection::m_total_count`, `uvm_sequence_library::seqs_distrib`, … — the
assoc/queue properties this pass's SUPPRESS half clears). **The LOCAL column does
not move at all, on any of the three tests**, which is the positive proof the law
stayed inside its scope and did not leak into `TaskFuncEmit.cpp`'s
element-signed subroutine population. The member survivors are pre-existing
missing objects (`uvm_random_seed_table_lookup`, six of them on SeqDriver), not
field residues.

---

## 7. EVERY GUARD I CITE, AND THE CONTROL I ACTUALLY RAN FOR IT

"A cited guard that does not exist can never read as green."

| guard | negative control (executed, with its output) | positive control |
|---|---|---|
| `ct8fields.py` UNMEASURED | `array_var ZZZ_NOT_A_CELL` → `UNMEASURED: no array_var header contains 'ZZZ_NOT_A_CELL'`, **exit 3** | real cells → the §3 tables |
| `ct8fields.py --defn` back-reference drop | a name whose only occurrences are references → `UNMEASURED: every … occurrence … is a bare back-reference` | real dumps → one row per object |
| `ct8grid.py` missing-dump | `/tmp/nonexistent_r10oth8.dump` → `UNMEASURED: cannot read dump …` + `UNMEASURED: one side has no dump`, **exit 3**. **This guard did not exist in the first draft** — it raised `FileNotFoundError` | real pairs → the §3 tables, exit 0 |
| `ct8grid.py` comparator self-check | golden vs GOLDEN → **22 cells, differing 0** | golden vs ours → 16 differing pristine, 4 patched (a1) |
| `ct8arm.sh` `SLANG_UHDM` required | `env -u SLANG_UHDM` → `SLANG_UHDM: set SLANG_UHDM to the build under test`, **exit 1** | both binaries named explicitly in every run |
| `ct8arm.sh` missing-input / uhdm-cmp-exits-0 | a source slang rejects → `NO_OUTPUT` + the diagnostic, **exit 6** (this actually fired on a1's first draft: `rand string`/`rand real` are illegal) | real arms → `CMP_FAIL` + both distance numbers |
| `ct8rows.sh` missing baseline | `/tmp/nope_r10oth8.csv` → `FATAL: missing baseline`, **exit 9** | the committed CSVs → 0 differing ROWS |
| `ct8rows.sh` whole-row incl. dump column | status flipped in a copy → **1 differing ROWS (2 diff row-sides)**; dump column alone changed → **1 differing ROWS** | the real CSVs → 0 |
| `ct8rows.sh` ROWS vs row-sides | the first draft reported `2` for one changed row; both numbers are now printed and labelled | 731 = 732 lines − header, 1588 = 1589 − header |
| `ct8reach.sh` SVSwitch self-check | assertion changed to `-eq 99` → `SELF-CHECK FAILED — the regex, not the corpus, changed`, **exit 4** (checked UNPIPED: a pipeline masks the exit status) | real corpus → **1**, exit 0 |
| `ct8census.sh` NO-SUCH-TEST vs UNMEASURED | `ZZZ_TYPO` → `NO-SUCH-TEST: ZZZ_TYPO under …`, **exit 1**, distinct from the UNMEASURED path | `SVSwitch` → the 0→1 / 1→0 census |
| `ct8nested.py` key correctness — **A DEFECT THIS SCRIPT SHIPPED WITH, caught by running it** | its first draft keyed objects on `hdr.split(', ')[0]`, which KEEPS the dump's indentation, so the same object at two depths made two keys and ALL 237 rows read `ONE-SIDE-ONLY` — a zero-information reading that looks like a catastrophic regression | keyed on the parenthesised name → SeqDriver **member 19→6, local 14→14**; ~~the sum matches `ct8census.sh`'s 25→12~~ — **verifier F5: it does NOT. The split sums to 33→20, not 25→12; only the DELTA (13) agrees, and the split also folds `ONE-SIDE-ONLY` missing-object rows in under a header that reads "disagreement". A cross-check that compares deltas is not a cross-check on totals — say which.** |
| `ct8movers.sh` MIXED vs ONLY-VPISIGNED | `Scoreboard/default` → **MIXED (170 non-vpiSigned lines)**, with the offending lines printed rather than summarised | the other eight movers → ONLY-VPISIGNED |
| `ctflake.sh` (reused unchanged from `r10oth7repro`) | four reps per binary → **two md5s on EACH binary**, so "nondeterministic" is a measurement | the vpiSigned line counts on that mover match the other movers exactly |
| `ct8census.sh` baked-path defect | the first draft had this worktree's ABSOLUTE path substituted into its heredoc; now `CT8DIR` | runs from the script's own directory |
| `byteverify.sh` (reused unchanged from `r10oth6repro`) | `SELFCHECK=1` → **678/679** flagged; `SELFCHECK1=1` → **exactly 1** | 0 movers on uhdm2rtlil |
| `ctcan2.sh` (reused unchanged from `r10oth7repro`) | `EXPECT_UNKNOWN` mismatch is fatal by construction | u2r CSV with `EXPECT_UNKNOWN=6` → `ok=1 changed=0 absent=0`, **PASS** |
| `canaries.sh` (reused unchanged from `r10uvm52repro`) | its own two controls are documented at its site | u2r CSV → `ok=8 changed=0 absent=0`, unknown-names 25 as expected for a u2r CSV |
| goldens harness | `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** | this worktree's build → **23 PASS** |
| binary staleness | md5 asserted in a SEPARATE command AFTER the link and BEFORE any sweep | `2e27ef16…` → `fc3c008b…` |

**CANARY COVERAGE, audited rather than cited.** Both scripts were run on both
corpora. `ctcan2.sh` is the only script that carries `EvalFunc*` (10 rows),
`ParamFile*` (8) and `Black*` (34), and `canaries.sh` carries the other 33 names;
neither supersedes the other, and the union is what §5/§6 report. **THE TWO LIVE
CONVERSIONS WERE CHECKED BY NAME, not by inference**: `InterfaceModPort`
`default` and `testflags` → `CMP_EQUAL/differ` **OK** in `canaries.sh` on the
SURELOG csv, and `BlackParrotComplex` `default` and `testflags` →
`CMP_EQUAL/differ` **OK** in BOTH scripts on the SURELOG csv. Both print
`UNKNOWN-NAME` on the uhdm2rtlil csv because neither test exists there — which is
a coverage fact worth stating rather than a green reading. The four slang-fenced
tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched.

---

## 8. RANKED RESIDUE — most reachable first, ONE consistent number per residue

**R0 — THE FOURTH `isSigned()` SITE, and this pass did not know it existed
(verifier F7, confirmed by the master in the shipped tree).**
`src/TypeEmit.cpp:14954`, `ln->VpiSigned(true)` gated on `leaf->isSigned()`, on
the element **`logic_net` of an `array_net`** — the same typedef-piercing
resolution the three `array_var` sites were just cured of. **NOT FIXED, and
deliberately so:** at NET scope golden's placement is genuinely different (arm a6
`g03` shows golden using a `logic_net` + `array_net` where we use an `array_var`,
which is residue R6), so copying the `array_var` law over would be guessing.
DIRECTION: **measure first** — build the net twin of arms a3/a7/a8 before
touching it. Reach: UNMEASURED.


**~~R1 — SVSWITCH'S NEW HEAD. Ours mints TWO `byte_typespec` objects for the ONE
written `byte` element type of `rand byte data[];`; golden mints ONE. DIRECTION:
share (DELETE the duplicate). Depth: object identity, not a field. Reach: 2
objects on SVSwitch.~~ REFUTED — the two sides mint the SAME NUMBER. The ids
`3771`/`1512` are `uhdm-cmp`'s two SIDES of one pairing, not two objects of
ours.** The verifier refuted the count (its **F2**, via `--stats` 4/4) and I
re-measured it a third way, by span, in the very dumps this pass produced:

**R1 (RE-CHARACTERISED BY THE MASTER — a FIELD + PARENT residue on ONE span).**
`byte_typespec` occurrences, own fields at own child depth, `/tmp/r10oth8_svs_*.dump`:

| span | occurrences G/O | golden own fields (top-level listing) | ours |
|---|---|---|---|
| `41:10` | 2 / 2 | `vpiSigned:1` | `vpiSigned:1` — EQ |
| `43:3` | 2 / 2 | `vpiSigned:1` | `vpiSigned:1` — EQ |
| `24:6` (`byte fcs;`, a plain scalar property) | 2 / 2 | `vpiParent` → `byte_var`, `vpiSigned:1` | **same — EQ** |
| **`23:6` (`rand byte data[];`, the ARRAY element)** | **2 / 2** | **`vpiParent` → `byte_var (work@packet::data)`, `vpiSigned:1`** | **NOTHING — no `vpiParent`, no `vpiSigned`** |

**Population is 4 spans on each side, each printed exactly twice** (once nested
under the class, once in the top-level typespec listing) — so nothing is
duplicated and nothing is missing. **One span of the four differs, and it is
exactly the ELEMENT TYPESPEC OF THE DYNAMIC ARRAY**: the plain scalar `byte fcs;`
one span below gets both fields from us, the array's element typespec gets
neither. DIRECTION: **ADD both fields**, at the `elemTs` mint in `emitClassDefn`'s
dynamic/queue/assoc arm — `VpiParent(reg)` (the element `byte_var`) and
`VpiSigned(true)` gated on clauses (b)+(c) of § arrayVarSignedWritten8.

**CONSEQUENCE FOR THE LAW, and it is a THIRD placement this pass did not know
about:** signedness rides the `array_var` **and the element TYPESPEC**, and never
the element **VAR**. The SUPPRESS half stays exactly as shipped; the typespec is a
separate carrier. Golden's own `24:6` row is the positive control — the fields we
already emit correctly for a scalar are the fields missing on the array.

The listing ORDER also differs (golden `41:10, 43:3, 23:6, 24:6`; ours
`23:6, 41:10, 43:3, … 24:6` far later), which is a `vpiParent`/last-lister
question — see the campaign law that a listing residue is usually a parent-policy
bug, not a naming one. Fix the two fields first and re-measure before touching
order.

**R2 (CARRIED) — we emit a DIFFERENT NUMBER of `class_typespec` objects than
golden: golden 35 / ours 32 on SVSwitch, +504 on SimpleUVM, +673 on
BuildUVMPkg.** Untouched and not re-measured by this pass; the figures stand as
`r10oth7repro/README.md` records them.

**R3 — a FIXED-SIZE unpacked-array CLASS PROPERTY is emitted as NOTHING by us.
DIRECTION: ADD the object. Depth: a whole missing shape. Reach: 2 of SVSwitch's
own class properties, plus arm cells a12/a17/a18.** Witnesses, named:
`Environemnt.sv:17` `virtual output_interface.OP output_intf[4];` and
`Environemnt.sv:20` `Receiver rcvr[4];` (**verifier F9** — the dump agrees with
`17:31` / `20:12`; the earlier `:16`/`:19` were off by one). We print
`class property type: FixedSizeUnpackedArrayType` and `continue`, which DELETES
the property from the class's `vpiVariables` listing. Measured consequence on
SVSwitch: golden has **5** distinct `array_var` names and we have **3** (the
earlier "12 objects / 8 objects" were dump-occurrence keys, not objects — verifier
F3; the TRUE object counts are 5 and 3). Golden gives `a12` `vpiSigned:1` and
`vpiArrayType:1`, so when this shape is built it needs § arrayVarSignedWritten8
as its FOURTH call site. **This is the most reachable residue this pass leaves on
the target.**

**R4 — a `real` / `shortreal` element of a dynamic/queue/assoc CLASS property is
unsupported (`class array property element`). DIRECTION: ADD. Reach: arm cells
a22 and d10; UNMEASURED in the corpus.** Golden gives the array_var no
`vpiSigned` there, so the law is already correct for it — only the object is
missing.

**R5 — the whole ARRAY declared through a TYPEDEF (`typedef byte barr_t[];
barr_t x;`) gets NO `vpiArrayType` in golden and `2` (or `4` for a queue
typedef) in ours. DIRECTION: DELETE the field. Reach: arm cells d04/d05/e04/e05;
UNMEASURED in the corpus.** `vpiSigned` is already correct on all four cells
after this pass; only the array-kind field remains.

**R6 — `reg signed x[]` and `time x[]` at MODULE scope are a `logic_net` +
`array_net` in golden and an `array_var` in ours. DIRECTION: REPLACE the object
KIND. Reach: arm cells g03/g04; UNMEASURED in the corpus.** This is why those two
cells read `UNMEASURED` on golden's side rather than `-`.

**R7 — a BOUNDED queue (`byte q[$:7]`) is `vpiArrayType:1` in golden and `4` in
ours. DIRECTION: REPLACE the value. Reach: arm cells f06/g06; UNMEASURED in the
corpus.** Independent of this pass's law: `vpiSigned` is EQ on both cells.

**R8..R12 (CARRIED, untouched, not re-measured)** — the brief's R3 (a written
`#(...)` over-extends our `class_typespec` span), R4 (a built-in class handle
outside a class should be `unsupported_typespec`), R5 (a nested class as a
subroutine local), R6 (class-handle method return name — RISKIEST, most of UVM)
and R8 (two to four NAME_ONLY `process` objects, i.e. R2 in another hat). Each
stands exactly as `r10oth7repro/README.md` records it.

**R13 (CARRIED, DELIBERATELY UNFIXED)** — law C's span ignoring
`VirtualInterfaceTypeSyntax::parameters`; golden's rule is
`parameters.end -> modport.end -> name.end`, **26 sites**, LATENT. Span changes
are this campaign's named over-fire class and this pass did not open one.

---

## 9. FILE MANIFEST AND EXACT COMMANDS

| file | what it is |
|---|---|
| `a1_class.sv` | arm 1 — 22 class-property cells: every array kind × every integer kind × rand/non-rand |
| `a2_module.sv` | arm 2 — the module twin of a1, cell for cell |
| `a3_elemkind.sv` | arm 3 — 11 class cells over element KINDS (typedef, enum, struct, class, string, signed vector) |
| `a4_modelem.sv` | arm 4 — the module twin of a3; **found the second defect** |
| `a5_written.sv` | arm 5 — 20 boundary cells, class and module halves in ONE Surelog run |
| `a6_kindgate.sv` | arm 6 — 14 cells pinning the KIND whitelist |
| `a7_fixedtd.sv` | arm 7 — 5 cells on the FIXED-size module site; **found the third site** |
| `a8_pkgtd.sv` | arm 8 — 12 cells, the PACKAGE-typedef distinguisher; the load-bearing arm |
| `a9_scope.sv` | arm 9 — the subroutine-local NEGATIVE CONTROL plus the witness standalone |
| `ct8arm.sh` | arm driver: `sed 1d` on both dumps, `[ -f ]` guards, judge = `diff -u`, cmp labelled HEAD DEPTH, `GOLDEN_ONLY=1` to measure golden while a build links |
| `ct8fields.py` | OWN-DEPTH field lister; nested fields in their own column; `--defn` drops back-reference occurrences; UNMEASURED never reads as "no difference" |
| `ct8grid.py` | the arm TABLE: four cells per row (own/nested × golden/ours), `UNMEASURED` for a missing object or a missing dump |
| `ct8all.sh` | runs all nine arms and prints all thirteen tables; the SAME script produces the pristine and patched readings |
| `ct8census.sh` | the PER-FIELD census for one corpus test, both sides, own depth; golden path read out of `cmds.txt`, never guessed |
| `ct8reach.sh` | corpus reach, ADD vs TD populations, per-test breakdown, SVSwitch `-eq 1` self-check |
| `ct8rows.sh` | the ROW gate: whole-row diff incl. the dump column, ROWS *and* row-sides, header-is-not-a-row |
| `ct8movers.sh` | MOVER ATTRIBUTION: ours-pristine vs ours-patched, `+`/`-` `vpiSigned` line counts and an ONLY-VPISIGNED / MIXED verdict per mover |
| `ct8nested.py` | splits the nested-element `vpiSigned` population into MEMBER and LOCAL and names the disagreeing objects — the instrument that keeps two opposite laws from being summed |

Reused unchanged, one instrument one location:
`tools/probe/r10oth6repro/byteverify.sh` (gate 5, both controls),
`tools/probe/r10oth7repro/ctcan2.sh` (supplementary canaries, `EXPECT_UNKNOWN`),
`tools/probe/r10uvm52repro/canaries.sh` (the 33-name list),
`tools/probe/r10oth7repro/ctheads.sh` (the before/after head table).

```sh
# arms, both binaries
SLANG_UHDM=/tmp/r10oth8_base/build/slang-uhdm ./ct8all.sh pri
SLANG_UHDM=$PWD/build/slang-uhdm             ./ct8all.sh fin
# the target, before and after
bash ../r10oth7repro/ctheads.sh /tmp/r10oth8_wd_svs_pri /tmp/r10oth8_wd_svs_fin SVSwitch
./ct8census.sh /tmp/r10oth8_wd_svs_pri default SVSwitch
./ct8census.sh /tmp/r10oth8_wd_svs_fin default SVSwitch
# gates 3 and 4 (own --out, own --workdir, committed baselines only READ)
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
  --out /tmp/r10oth8_u2r_fin.csv --workdir /tmp/r10oth8_wd_u2r_fin
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 \
  --out /tmp/r10oth8_sl_fin.csv --workdir /tmp/r10oth8_wd_sl_fin
./ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/r10oth8_u2r_fin.csv
./ct8rows.sh results/golden_surelog.csv  /tmp/r10oth8_sl_fin.csv
# gate 5
bash ../r10oth6repro/byteverify.sh /tmp/r10oth8_wd_u2r_fin /tmp/r10oth8_wd_u2r_pri
bash ../r10oth6repro/byteverify.sh /tmp/r10oth8_wd_sl_fin  /tmp/r10oth8_wd_sl_pri
# canaries, BOTH scripts, BOTH corpora
EXPECT_UNKNOWN=6 bash ../r10oth7repro/ctcan2.sh results/gate_uhdm2rtlil.csv /tmp/r10oth8_u2r_fin.csv
EXPECT_UNKNOWN=1 bash ../r10oth7repro/ctcan2.sh results/golden_surelog.csv  /tmp/r10oth8_sl_fin.csv
bash ../r10uvm52repro/canaries.sh results/gate_uhdm2rtlil.csv /tmp/r10oth8_u2r_fin.csv
bash ../r10uvm52repro/canaries.sh results/golden_surelog.csv  /tmp/r10oth8_sl_fin.csv
```
