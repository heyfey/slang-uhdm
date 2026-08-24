# r10buvm34 — § foreachScopedArrayLoopVarIntFallback34

**The head.**  The LOOP VARIABLE `i` of the very `foreach` pass 33 fixed —
`foreach (this_type::m_typewide_sequences[i])`, the header of
`uvm_sequence_library::init_sequence_library`
(`UVM/uvm-1.2/src/seq/uvm_sequence_library.svh:496`, `pp_output/uvm_pkg.sv:56591`)
— was the first object the official `uhdm-cmp` disagreed on for **SIX
row-modes** at base `bd8cbb7`: SeqDriver, BuildUVMPkg **and MiniAmiq**,
default and testflags, all six at 56 cmp lines with exactly one `^LHS:`.

```
LHS (golden)  int_var   (uvm_pkg::uvm_sequence_library::init_sequence_library::i)
              line 496:44-496:45   vpiParent -> foreach_stmt
              vpiName:i
              vpiTypespec -> ref_typespec -> int_typespec        (NO name, NO span)
RHS (ours)    array_var (…::i)  @496:44-496:45
              vpiName:i
              vpiTypespec -> ref_typespec -> array_typespec      (NO name, NO span)
```

Re-measured on THIS worktree's own pristine build before any code was written
(`rowheads.sh` over this pass's own pristine sweep): the same object on all six
rows, and the SeqDriver/default head log is byte-identical to the master's
`/tmp/seqdriver_head_bd8cbb7.cmp` once arena ids are normalised away.

The only Compare-visible difference is the KIND and, through
`ref_typespec::Actual_group`, the typespec kind: both sides carry the same
`vpiName`, the same span, the same parent.  Spans and fullnames are read by no
generated `Compare`.

---

## 1. The decoded law

> A `foreach` whose ARRAY REFERENCE is WRITTEN with a `::` scope gives EVERY
> loop variable of that list Surelog's **fallback `int_var` over a BARE
> `int_typespec`** — no name, no span, no ranges — whatever the array's real
> type is, whatever the loop-list arity is, and in every home where the loop
> variable resolves at all.

**Surelog, line by line.**  `UhdmWriter::swapForSpecifiedVar`
(`src/DesignCompile/UhdmWriter.cpp:2490`) is the ONLY producer of a resolved
loop variable.  `CompileStmt.cpp:548-563` mints every loop variable as a
`ref_var` over an `unsupported_typespec` named for the index and registers it
with `component->needLateTypedefBinding(ref)`; `lateTypedefBinding`
(`UhdmWriter.cpp:2573`) later walks that list, and when the name resolves to no
enclosing typedef and the object's parent is a `foreach_stmt` (`:3139-3148`) it
hands every `VpiLoopVars()` entry to `swapForSpecifiedVar`.

That function types the loop variable **from the object the foreach lists
under `vpiVariables`** — and reads only TWO kinds:

* `uhdmhier_path` (`:2507` for the vector arm, `:2521` for the singular one) —
  fed to `decodeHierPath` AS WRITTEN;
* `uhdmref_var` (`:2529`) — a synthetic one-element `hier_path` is built from
  its `VpiName()` and fed to the same call.

**Nothing else is read at all.**  Since
§ foreachScopedArrayWrittenClassVar33 the listed object for a `::`-written
spelling is a `class_var` (`CompileType.cpp:614` is the unconditional default
for a data member: `insertDataType` registers typedefs and class definitions,
never variables, so both lookups miss BY CONSTRUCTION).  A `class_var` is
neither a `hier_path` nor a `ref_var`, so `indexTypespec` stays null,
`getSimpleVarFromTypespec` is never called, and `:2546-2553` runs:

```cpp
} else {
  int_var* ivar = s.MakeInt_var();
  ref_typespec* rt = s.MakeRef_typespec();
  rt->Actual_typespec(s.MakeInt_typespec());   // bare: no name, no span
  rt->VpiParent(ivar); ivar->Typespec(rt);
  swapVar = ivar;
}
```

then copies the ORIGINAL `ref_var`'s name, parent and full span onto it — which
is why golden's `int_var` keeps `vpiName:i` at `496:44-496:45` while its
`int_typespec` carries neither.

**The RESOLVABLE table is the control, and it is `getSimpleVarFromTypespec`
(`CompileType.cpp:78-247`) applied to the ARRAY's own typespec** — measured
cell by cell on `g34a1`, never assumed:

| the array (a class property, iterated BARE) | golden's loop variable |
|---|---|
| `int q[$]` / `int d[]` / `int f[4]` | `array_var` + bare `array_typespec` |
| `string sq[$]` / `key34 cq[$]` / `e34_t eq[$]` / `sp34_t pq[$]` | `array_var` + bare `array_typespec` |
| `int m[3][4]`, BOTH slots | `array_var` + bare `array_typespec` |
| `ta34_t t` (a TYPEDEF'd fixed array) | `array_var` + `array_typespec 'ta34_t'` **at the typedef's span** |
| `int as[string]` | `string_var` + the index `string_typespec` |
| `int ai[int]` | `int_var` + the index `int_typespec` **at the index type's span** |
| `int ac[key34]` | `class_var` + `class_typespec 'key34'` |
| `bit [7:0] v` (a PACKED vector, no unpacked dim) | `bit_var` + the vector's own `logic`/`bit_typespec` |

`uhdmarray_typespec` recurses into `Index_typespec()` when there is one (the
associative rows) and mints an `array_var` when there is not (every
non-associative row) — so the table is a consequence of ONE switch, and the
`::`-written face never reaches it.

**Our bug.**  `StmtEmit.cpp`'s `declLoopVar` typed the loop variable from
slang's RESOLVED array symbol, which sees straight through the `this_type`
typedef and through the `::` qualifier: for `m_typewide_sequences`
(`static uvm_object_wrapper m_typewide_sequences[$]`) that is
§ foreachClassPropArrayVar21's `array_var` + `array_typespec`.  The fix reads
the same WRITTEN-syntax predicate pass 33 already built (`scopedArr33`, backed
by `foreachScopedArrayName33`) and takes the int fallback instead.

**Why the patch is three lines of logic.**  Every resolved arm in
`declLoopVar` is guarded on `!lv`, so setting `lv`/`lts` to the int pair BEFORE
them makes them all skip — the same shape as Surelog skipping
`getSimpleVarFromTypespec` when `indexTypespec` is null.  The one arm that was
NOT `!lv`-guarded (the § foreachLocalArrayVar20 `tfLocalArrayTs9` lookup) now
is; it is unreachable for a scoped spelling either way, and the guard is what
makes the "set `lv` first" reading true rather than nearly true.
The UNRESOLVED arms are untouched and come FIRST: a name that already resolves
in the enclosing scope, a nested foreach re-listing an open variable, and the
`classMethodNoBind || pkgDefViewBody9 || pkgImportCloneEmit` copies that golden
never runs `lateTypedefBinding` over.

---

## 2. The purpose-built grids (three arms, both views, read cell by cell)

`gridcmp34.py` reads every `foreach` loop-variable SLOT of an arm on all three
sides — golden, the PRISTINE binary, the PATCHED one — as a MULTISET keyed on
(view, foreach span, SLOT INDEX, loop-var name), and votes SAME / FIXED /
RESIDUE / **BROKEN** (pristine-right, patched-wrong: the number that must be
zero).  It never keys on the dump's parenthesised fullname (that is the
`vpiFullName`, which no `Compare` reads — r10vbuvm33's phantom-residue trap)
and never keeps a first/last writer per source line (buvm19/22's trap).

| arm | view | FIXED | SAME | RESIDUE | **BROKEN** |
|---|---|---|---|---|---|
| `g34a1` | def | 12 | 11 | 5 | **0** |
| `g34a1` | elab | 0 | 0 | 28 | **0** |
| `g34a2` | def / elab | 13 / 13 | 19 / 19 | 25 / 25 | **0 / 0** |
| `g34a3` | def / elab | 8 / 8 | 12 / 12 | 6 / 6 | **0 / 0** |

`dist34.py` turns the same parse into an order-blind MULTISET DISTANCE to
golden, so an arm is SCORED rather than eyeballed — a landing may never raise
`dist(golden, patched)` above `dist(golden, pristine)`:

```
g34a1  def   34 -> 10      g34a1  elab   62 -> 38
g34a2  def   72 -> 46      g34a2  elab  185 -> 113
g34a3  def   28 -> 12      g34a3  elab   58 -> 20
```

**Every arm-view strictly better; WORSE = 0; BROKEN = 0.**

`g34a1.sv` — **THE ARRAY-TYPE MATRIX**, one out-of-body class method (the
corpus home shape), thirteen arrays each iterated TWICE, once `this_type::<a>`
and once bare: queue / dynamic / fixed of int, queue of string, queue of class
handles, `[string]` / `[int]` / `[<class>]` associatives, queue of enum, queue
of packed struct, a PACKED VECTOR, a 2-D fixed array `[i,j]` and a typedef'd
fixed array.  **Golden answers `int_var` + bare `int_typespec` for all
thirteen scoped cells** (fourteen slots), while the bare twin of each answers
the RESOLVABLE table of §1 — the two halves of the same statement, in the same
function, differing only in the written qualifier.  Two scoped cells agreed
already by coincidence (`[int]` associative and the packed vector both fall to
`int_var` on our side too); the other twelve slots are the FIXED column.

`g34a2.sv` — **ARITY x WRITTEN FORM**: `[i]`, `[i,j]`, `[,j]`, `[i,]`,
`[i,j,k]`, `[,,k]`, `[i,,k]` over a 3-D static array, scoped and bare, plus a
DOTTED (`h34.i2d34`, a `hier_path` — § foreachHierPathAlwaysRes21) and a
`this.`-prefixed reference and a MODULE home with a three-segment qualifier.
Every NAMED slot of every scoped arity goes to golden's `int_var`; the
`vpiNullOp` placeholders are untouched.  The arm also pins the loop-list SHAPE
residue R2 below.

`g34a3.sv` — **HOMES**: in-body method, static method, package free function,
package task, interface function, program initial, module initial, module task,
`always` and `fork…join_none`.  Golden resolves the loop variable — and
therefore answers `int_var` for the scoped cell — in the package homes AND in
every module home; in `g34a3`'s INTERFACE and PROGRAM homes it resolves
NOTHING and the scoped and bare cells alike stay unresolved `ref_var`s.
**The verifier measured the distinguisher and it is not the home KIND —
it is INSTANTIATION** (`r10vbuvm34repro/v34g.sv`, which holds the text
constant and varies only whether a `topg34` instantiates the unit): an
INSTANTIATED interface and an INSTANTIATED program BOTH resolve the loop
variable and both answer golden's bare `int_var` for the scoped cell, which
this law then matches; `g34a3`'s `if34` and `pgm34` are never instantiated,
which is why they resolve nothing.  See residue R1.

`g34a1`'s ELAB column is all RESIDUE for a reason that is not this law: in the
elaborated view we emit FOUR listings of that package body where golden emits
THREE, so no cell can be SAME.  The distance still halves, and pristine and
patched disagree with golden on exactly the same cells.

---

## 3. The corpus census (question 1, answered over all 956 databases)

`r10buvm34cen.cpp` enumerates ONE family, `FELV`, by the SAME rule on both
sides: one row per (`foreach_stmt`, loop-variable SLOT), carrying the loop
variable's KIND and ACTUAL typespec as PAYLOAD and the ARRAY reference's kind,
name, `ascoped` flag, arity and skip count as SPLIT columns.  The KEY is
(test, mode, HOME, foreach span, SLOT, loop-var NAME) — the kind and the
typespec are exactly what the two producers disagree about, so a key that
carried them would hide every disagreement as a MISSING/EXTRA pair (buvm33's
rule).  `sweepcen34.sh` ran it over BOTH sides of every cell of the pristine
AND the patched surelog workdirs (956 databases x 2 modes; 617 cells have a
missing side and are COUNTED, not skipped) and over both uhdm2rtlil workdirs
(1358 cells).  `cen34.py` joins as a MULTISET.

```
                                        pristine      patched
FELV  IDENTICAL                            4554         4560   (+6)
      PAIRED-DISAGREE                       890          884   (-6)
      MISSING-OURS / EXTRA-OURS            0 / 0        0 / 0
  split by the array reference's WRITTEN form (read off GOLDEN):
      ascoped=Y  IDENTICAL / DISAGREE     7 / 6       13 / 0
      ascoped=N  IDENTICAL / DISAGREE  4547 / 884   4547 / 884
  the disagreeing cells by array-reference kind:
      ref_var 797   hier_path 87   class_var 6        ref_var 797  hier_path 87
```

Disagreement KEY SETS compared directly, pristine vs patched:
**NEW = 0, GONE = 6.**  Our cells that MOVED: **6 — TO-GOLDEN 6 /
AWAY-GOLDEN 0 / STILL-WRONG 0.**  The GOLDEN side of the two sweeps is
identical row for row, which is the control that the census is reading the
change and not the weather.

**The corpus's whole scoped-foreach loop-variable population is 13 cells** —
ONE written name (`this_type::m_typewide_sequences`), ONE loop variable (`i`),
ONE slot, ONE home (`uvm_sequence_library::init_sequence_library`), in nine
databases.  Six disagreed and now agree; the other seven were ALREADY
identical, and they are the control that the law is not "every scoped cell":

* `default/SimpleUVM`, `testflags/SimpleUVM`, `default/Scoreboard` — golden is
  `int_var` and so were we, because § classPropUnitImport21's `$unit`-import
  gate already withheld resolution in those three designs.  This law makes the
  answer independent of that gate, which is why it is the same object.
* the four WILDCARD-IMPORT CLONE copies (`svaunit_pkg::…` in MiniAmiq both
  modes, `adpcm_pkg::…` in SeqDriver both modes) — golden lists TWO unresolved
  `ref_var`s and so do we (§ cloneForeachLoopVarUnresolved37).

**uhdm2rtlil has ZERO `foreach_stmt` objects at all** in the 1358 censused
cells, on either side, in either mode — so `scopedArr33` can never be true
there.

Loop-list SHAPES in the corpus, read off golden: 9402 rows of arity 1, 18 rows
of arity 2, and 12 rows of arity 4 with ONE `vpiNullOp` — an INTERIOR skip,
which both producers already agree on (`MISSING-OURS / EXTRA-OURS 0 / 0` is
that agreement).  A LEADING or TRAILING skip has zero corpus incidence (R2).

**The judge-visible half of the residue.**  Of the 890 pristine
PAIRED-DISAGREE cells, **828 differ ONLY in a typespec SPAN**, which no
generated `Compare` reads; **62 are judge-visible**, and this law owns exactly
6 of them:

```
pristine  JUDGE-VISIBLE 62 = 38 + 9 + 9  (bare face)  +  6  (THIS LAW)
patched   JUDGE-VISIBLE 56 = 38 + 9 + 9  (bare face)  +  0
```

---

## 4. Mover prediction and attribution

`PREDICTION.txt` was written from the PRISTINE databases BEFORE the patched
binary was built: **6 databases, by name** — `{default,testflags}` x
`{SeqDriver, BuildUVMPkg, MiniAmiq}` — and uhdm2rtlil **zero**, both modes.

Measured: `byteverify.sh SELFCHECK=1` reports **MOVERS 6 / 956** — exactly the
six predicted names and nothing else (SELFCHECK 955/956, so the instrument can
see) — and **0 / 1358** on uhdm2rtlil (SELFCHECK 1357/1358).

`movers34.sh` attributed all six ORDER-BLIND (both dumps id- and
path-normalised, `LC_ALL=C sort`ed — the only sound attribution for SeqDriver,
which r10vbuvm32's F3 proved is a COIN):

```
default/BuildUVMPkg 8   default/MiniAmiq 8   default/SeqDriver 8
testflags/BuildUVMPkg 8 testflags/MiniAmiq 8 testflags/SeqDriver 8    = 48 lines
```

**0 unattributed lines**: every one of the 48 is
`\_array_var: (…::init_sequence_library::i)` -> `\_int_var: (…::i)` or the
`\_array_typespec:` -> `\_int_typespec:` under it.  8 lines = 2 cells (the
variable listed once under `vpiLoopVars` and once as its ref_typespec's
`vpiParent`) x 2 sides x 2 objects.

---

## 5. Head movement

`rowheads.sh` on the pristine and patched workdirs of this build:

| row | mode | pristine | patched | head object |
|---|---|---|---|---|
| SeqDriver | default | 56 | **17** | int_var `i`@496:44 **CLEARED** |
| SeqDriver | testflags | 56 | **17** | same |
| BuildUVMPkg | default | 56 | **17** | int_var `i`@56591:44 **CLEARED** |
| BuildUVMPkg | testflags | 56 | **17** | same |
| MiniAmiq | default | 56 | **17** | int_var `i`@496:44 **CLEARED** |
| MiniAmiq | testflags | 56 | **17** | same |
| SimpleUVM | both | 17 | 17 | unchanged (`logic_net work@top.p`) |
| Scoreboard | default | 17 | 17 | unchanged |
| Earlgrey_0_1 | both | 64 | 64 | unchanged (`constant`@12:40) |
| Rggen | default | 0 | 0 | still equal |

The six target row-modes' head **cleared**, and all six land on the object
Scoreboard/default already stood on — so SEVEN row-modes now share ONE head
(R0).  One `^LHS:` per run everywhere.

---

## 6. Gates (all green, on this worktree's own build)

Every baseline below is this worktree's OWN pristine sweep, run with the frozen
pristine binary before any edit, plus the COMMITTED `results/*.csv`.

* build both binaries `-j 2`, md5 separately: pristine
  `d294370b9db2b02af17b0190d3bc2144`, patched
  `ab753ec4cf41cdb620282d6e1b2ab31d`; both frozen `chmod 555` before any sweep,
  and every `cmds.txt` audited BY BINARY PATH (not by the string `slang-uhdm`,
  which also matches the golden cache directory): of 1573 surelog `cmds.txt`
  **1523 name the frozen binary and 50 name none at all** (golden-cache-only
  cells — every `*slang-uhdm*` token in those 50 is a
  `~/.cache/slang-uhdm-goldens/<hash>` path), and of 1462 uhdm2rtlil `cmds.txt`
  **1458 name it**.  **Zero cells, in either corpus, in either sweep, name the
  main-tree binary OR this worktree's `build/slang-uhdm`.**
* `tests/check_goldens.sh` with `SLANG_UHDM` exported explicitly to the patched
  binary: **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false`:
  **0 PASS / 23 FAIL**.
* uhdm2rtlil testflags AND default: **679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL** in both modes (identical to pristine); `ct8rows.sh`
  **0 differing rows** against the committed `results/gate_uhdm2rtlil.csv` AND
  against this build's own pristine sweep, in BOTH modes, status AND dump
  column.
* surelog `--mode both`, 1588 rows: **937 CMP_EQUAL / 567 SLANG_REJECT /
  48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE /
  2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM** — identical to pristine;
  `ct8rows.sh` **0 differing rows** against the committed
  `results/golden_surelog.csv` and against the pristine sweep.  **NO ROW IS
  CONVERTED** and `results/*.csv` is untouched.
* `byteverify.sh SELFCHECK=1`: **6 / 956** movers (all predicted BY NAME,
  SELFCHECK 955/956) and **0 / 1358** on uhdm2rtlil (SELFCHECK 1357/1358).
* canaries `ok=52 changed=0 absent=0` / `ok=8 changed=0 absent=0`;
  `EXPECT_UNKNOWN=1` and `EXPECT_UNKNOWN=6` `ctcan2.sh` PASS on both corpora;
  `canaudit.sh canaries.sh ctcan2.sh` run FROM THIS DIRECTORY:
  **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* protected databases by name, md5 vs the pristine sweep, BOTH modes:
  InterfaceModPort, BlackParrotComplex, YosysOldOr **SAME**; SVSwitch
  `4842211c4030`; YosysVerx `6ccda350c24a`.
* boundary gate `bound34.sh` over a COPY of the whole `tools/probe` tree (3645
  `.sv`/`.v` arms), four configurations — see `BOUNDARY.txt`.
* the four slang-fenced tests are never dispatched and never spelled here.

---

## 7. Residues and R0

* **R1 — an UNINSTANTIATED interface / program home resolves NOTHING in
  golden.**  `g34a3` cells F1/F2 and G1/G2: golden's loop variable is an
  unresolved `ref_var` + `unsupported_typespec` for the scoped AND the bare
  spelling alike, where WE list a resolved variable.  The verifier's `v34g`
  arm corrects the framing this note first carried ("the INTERFACE and PROGRAM
  homes resolve NOTHING"): with the SAME text INSTANTIATED, golden resolves
  the loop variable in an interface function AND in a program initial, and
  answers the bare `int_var` for the scoped cell — both are FIXED cells of
  this law, not residues.  The unresolved reading is
  § foreachLoopVarObjs9's recorded R3 (`writePackage` is the writer that runs
  `lateTypedefBinding` on an elaborated listing) reaching a unit that is never
  elaborated, and it is PRE-EXISTING: on the scoped cell pristine
  said `array_var` and patched says `int_var`, both two multiset units from
  golden's `ref_var`, so `dist34.py` records no change there and the arm's
  total still halves.  It is the LARGEST corpus residue on this face —
  38 of the 56 judge-visible cells left are MiniAmiq's
  `svaunit_vpi_interface` interface-homed foreaches (the verifier confirmed
  the home and the count) — and it is a law of its own (which home resolves at
  all), not this one.  Those 38 are BARE spellings, so they are outside this
  law's face whatever the home rule turns out to be.
* **R2 — the LEADING / TRAILING skipped-slot SHAPE.**  Surelog's
  `CompileStmt.cpp:536-585` does NOT emit a `vpiNullOp` for a leading or a
  trailing empty slot: `foreach (a[,j])` is TWO entries, an EMPTY-NAMED
  `ref_var` at the comma's column followed by `j`, and `foreach (a[i,])` is
  ONE entry — only an INTERIOR `,,` produces the placeholder.  We emit a
  `vpiNullOp` for every skipped dimension, so `[,j]` and `[,,k]` are
  misaligned and `[i,]` is one entry too long.  `g34a2` measures all four
  spellings on both faces; pristine and patched are IDENTICAL on every one of
  them.  Corpus incidence **zero** (the corpus's only skipped slots are 12
  interior-`,,` rows, on which both producers already agree), which is why
  this pass does not model it.
* **R3 — the RESOLVABLE table is still approximated on the BARE face.**  Two
  `g34a1` bare cells are judge-visible: a PACKED VECTOR (`bit [7:0] v`) is
  golden's `bit_var` + the vector's own typespec against our `int_var`
  (r10vbuvm33's R-V4), and a TYPEDEF'd fixed array binds golden's
  `array_typespec 'ta34_t'` where ours is nameless.  `g34a3` adds a third: a
  package-level `string pv34[$]` iterated BARE is golden's `array_var` and our
  `string_var` — § foreachPkgClassArrayVar25 covers only class-handle elements
  where Surelog's rule is "any non-associative array_typespec".  All three are
  identical in pristine and patched.  **The verifier measured this residue's
  true width** on `r10vbuvm34repro/v34a.sv`, which iterates thirteen
  PACKAGE-LEVEL arrays bare in one package function: golden answers
  `array_var` + a bare `array_typespec` for EVERY non-associative one — queue,
  dynamic, fixed, queue-of-string, queue-of-class, queue-of-enum,
  queue-of-packed-struct, multi-dim (both slots) — and the typedef'd one keeps
  the typedef's NAME; only `[string]` and `[<class>]` recurse to the index.
  We drill to the element in ten of the thirteen.  So the package-level bare
  face is a THIRTEEN-cell residue, not the one string-queue cell `g34a3`
  showed; it is unchanged by this pass (pristine and patched agree cell for
  cell) and it is § foreachPkgClassArrayVar25's natural next widening.
* **R4 — 828 of the corpus's 884 remaining PAIRED-DISAGREE cells differ ONLY
  in a typespec SPAN** (golden binds the DECLARATION's typespec object, we
  mint a fresh one at `0:0`).  No generated `Compare` reads `VpiLineNo` /
  `VpiColumnNo`, so they are invisible to the judge; they are recorded rather
  than dressed up because the census counts them.
* **R5 — the remaining 56 judge-visible bare-face cells** are five distinct
  (array, loop-var) pairs: 38 in MiniAmiq's interface home (R1), and 18
  `uvm_phase` cells where an associative `[uvm_phase]` / `[uvm_reg_map]` index
  makes us answer `class_var` while golden answers `int_var` or `array_var`
  (the § foreachAssocIndexVar19 index rule reaching a cell whose array
  reference is a `hier_path` with an EMPTY name).  Untouched here.
* **R6 — the elaborated LISTING COUNT of `g34a1`**: golden emits three copies
  of that package body, we emit four.  Identical in pristine and patched;
  r10vbuvm33 recorded the same shape as its R-V3.

### R0 — the next head

With this landed, **SEVEN row-modes stand on ONE object** — SeqDriver,
BuildUVMPkg and MiniAmiq in both modes plus Scoreboard/default, all at 17 cmp
lines:

```
LHS: <null>
RHS: ref_typespec (uvm_pkg::uvm_sequence_library::execute)
     vpiParent -> operation @115:55-115:100 (56957:55 in BuildUVMPkg)
     vpiActual -> logic_typespec
```

Decoded with RESUME §9's head rule: `LHS: <null>` with a full RHS is the
SINGULAR overload's MIRROR — **OURS carries a field golden lacks**.  The owner
is the `vpiOpType:67` conditional operation of
`uvm_sequence_library::execute`'s `seq_or_item.is_item() ? "item " : "sequence"`
report string, and we bind a `vpiTypespec` (a `ref_typespec` over a
`logic_typespec`) onto it where golden's operation carries none.  It was
MASKED, not created: the 48 attributed mover lines contain zero lines
mentioning that operation or its typespec, so our object is byte-identical
before and after.  Worth SIX row-modes at once, and Scoreboard/default is
already there.

SimpleUVM stays at 17 on a different object (`logic_net work@top.p` @263:3 —
uvm117's target), Earlgrey_0_1 at 64 (`constant`@12:40 — earl80's), Rggen at 0.

---

## 8. Files

* `r10buvm34cen.cpp` + `build34.sh` — the `FELV` census, linked STATICALLY
  against `~/.local` UHDM so it reads exactly the databases the sweeps wrote.
* `sweepcen34.sh` — the census over a whole verify_golden workdir, both sides,
  both modes; a missing side is counted, never skipped.
* `cen34.py` — the symmetric multiset join (`--only-disagree`, `--filter`,
  `--by split|kind`); the key deliberately excludes the kind and the typespec.
* `gridcmp34.py` — golden vs pristine vs patched per loop-variable SLOT, with
  the SAME / FIXED / RESIDUE / **BROKEN** verdict; a view-general MULTISET.
* `dist34.py` — order-blind multiset DISTANCE to golden per arm-view
  (`--proj kind` strips spans).
* `arm34.sh` — one arm, both views, golden vs one binary, every command and rc
  echoed into `cmds.txt`.  `cells34.sh` — the same for all three sides at once.
* `movers34.sh` — order-blind mover attribution.
* `bound34.sh` — the boundary gate (default `OUT` names THIS pass, closing
  r10vbuvm33's R-V5); `coin34.sh` — the same-binary-twice nondeterminism
  control.
* `g34a1.sv` / `g34a2.sv` / `g34a3.sv` — the purpose-built goldens.
* `PREDICTION.txt` — the mover prediction, written before the patched sweep.
* `BOUNDARY.txt` — the boundary-gate results, arm by arm.
* `byteverify.sh` / `canaries.sh` / `ctcan2.sh` / `canaudit.sh` /
  `rowheads.sh` — the shared gate scripts, copied so `canaudit.sh` runs here.

The adversarial verifier's own instruments, arms and re-measured gates are in
`tools/probe/r10vbuvm34repro/` (`README.md`, `GATES.txt`, `BOUNDARY.txt`,
`ARMS.txt`).
