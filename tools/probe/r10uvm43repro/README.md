# r10uvm43 — UVM pass 43

Pass 42 closed with a ranked-#1 that its own verifier had already measured:
*golden applies the per-declaration-clone law to `typedef int uvm_action` too,
so widen the bit/logic kind gate against `int_typespec`.* The instruction was
to MEASURE the gate before widening it. Measuring it did two things:

1. it **confirmed the gate is incomplete** — golden clones for every INTEGER
   ATOM and for `string`, not just for `bit`/`logic`, and it also **excludes a
   CHAINED typedef**, which nobody had looked at; and
2. it **refuted the framing of the corpus payoff**. The single `int_typespec`
   row LISTDIRECT was pointing at is a position **golden leaves EMPTY**, so
   widening the gate cannot converge it — it would swap one non-matching
   `VpiName` for another and lower a ONE-SIDED metric by 1 per test.

Chasing (2) is what found the pass's real subject: **a FOURTH copy of the
associative-INDEX rule that never consulted the typedef registries at all.**

## 1. § tdAtomKindGate43 + § tdChainNoClone43 — the gate, measured per KIND

Arm `t60a` carries ONE typedef per base kind through both container positions
(an unpacked array's ELEMENT typespec, an associative array's INDEX typespec) in
a package, a class, a function body and a module. New probe `r10uvm43cp` prints,
per `array_typespec`, WHAT OBJECT sits in each position — kind, name, and
whether it is a LISTING object / a CLONE (it carries a `Typedef_alias`) / a
plain fresh object. Golden's t60a then states the gate in one table:

| index type | golden binds | in the gate? |
|---|---|---|
| `int`, `int unsigned` | `int_typespec 't_int'`/**CLONE**@28:11 | YES (new) |
| `byte` | `byte_typespec 't_byte'`/**CLONE** | YES (new) |
| `shortint` | `short_int_typespec 't_sint'`/**CLONE** | YES (new) |
| `longint` | `long_int_typespec 't_lint'`/**CLONE** | YES (new) |
| `integer` | `integer_typespec 't_integer'`/**CLONE** | YES (new) |
| `time` | `time_typespec 't_time'`/**CLONE** | YES (new) |
| `string` | `string_typespec 't_str'`/**CLONE** | YES (new) |
| `bit [7:0]` | `bit_typespec 't_bit8'`/CLONE | yes (pass 42) |
| `logic`, `reg [3:0]` | `logic_typespec 't_log1'`/CLONE | yes (pass 42) |
| `enum` | `enum_typespec 'pk60::t_enum'`/**LISTED** | no |
| packed / unpacked `struct` | `struct_typespec 'pk60::t_pstr'`/**LISTED** | no |
| **a typedef OF a typedef** | `bit_typespec 'pk60::t_chain'`/**LISTED** | **no — NEW EXCLUSION** |
| `real`, `shortreal`, `union`, class handle | — | **UNMEASURED, left out** |

So the gate is the ATOM kinds, and the same table holds for a MODULE-scope
typedef (`m_int` -> CLONE, `m_chain` -> LISTED, arm `t60b`).

Two honest notes on that table:

* the four bottom rows are **out because they are UNMEASURED, not because they
  were shown to bind directly**: Surelog emits no container typespec at all for
  a `real`/`shortreal`/`union` package array in t60a and turns the class-handle
  array into a `logic_net` + `unsupported_typespec`, so the arm cannot see them.
  A law that only ever saw one spelling has an unmeasured half; this one has
  three and they are NAMED rather than assumed away.
* **§ tdChainNoClone43** is consistent with what golden's chain listing object
  already IS: Surelog gives it a `Typedef_alias` of its own (`bit_typespec
  'pk60::t_chain' LISTED alias=t_bit8`), i.e. it is already the named alias
  object, and cloning it would mint a second one. Implemented on the AST side
  (`alias.targetType.getType().kind == TypeAlias`) rather than on
  `base->Typedef_alias()`, so it cannot mis-fire on any other object our own
  emitter happens to have given an alias to.

## 2. § assocIdxSiteFour43 — the site the registry was never asked

`assocIndexTs` is the associative-INDEX rule and its FIRST arm is
`sharedAliasTs`. Three sites call it (`emitAssocDims`' outer and inner
dimension = class properties, and the subroutine-local shape in `TaskFuncEmit`).
`emitDynArrayVar` — the MODULE / PACKAGE / interface instance-level `array_var`,
reached only from `ModuleEmit.cpp:5926` — **open-codes the tail of that function
and starts at the CANONICAL kind**, so a TYPEDEF-NAME index fell through to the
keyword arms: an UNNAMED typespec spanned at the index BRACKET, and the WRONG
KIND whenever the canonical type is not a predefined integer.

Measured, arm `t60b` (module scope), golden vs HEAD:

| written index | golden | HEAD |
|---|---|---|
| `[m_bit8]` | `bit_typespec 'm_bit8'`/CLONE@36:11 | `logic_typespec '<unnamed>'`@47:19 |
| `[p_bit8]` | `bit_typespec 'p_bit8'`/CLONE@24:11 | `logic_typespec '<unnamed>'`@66:20 |
| `[p_enum]` | `enum_typespec 'pk61::p_enum'`/LISTED | `logic_typespec '<unnamed>'`@71:20 |
| `[p_chain]` | `bit_typespec 'pk61::p_chain'`/LISTED | `logic_typespec '<unnamed>'`@69:20 |
| `[p_int]` | `int_typespec 'p_int'`/CLONE@16:11 | `int_typespec '<unnamed>'`@53:20 |
| `[p_byte]` | `byte_typespec 'p_byte'`/CLONE@17:11 | `byte_typespec '<unnamed>'`@45:19 |
| `[p_str]` | `string_typespec 'p_str'`/CLONE@23:11 | `string_typespec '<unnamed>'`@64:22 |

`VpiType` and `VpiName` are both COMPARED fields, so every row is a cmp
difference. **A WITNESS FINDS SITES CODE-READING MISSES**: pass 42's verifier
enumerated the `sharedAliasTs` CONSUMERS and this site is not one of them — it
is a place the registry was never asked, and only a two-sided probe (what does
golden put in the position?) could point at it.

The fix prepends the registry arm (`sharedAliasTs` + `tdVecNamedClone42`) and
**keeps the keyword arms as the fallback** rather than delegating to
`assocIndexTs` wholesale: this site sets `VpiSigned` on a signed
predefined-integer index and `assocIndexTs` does not, so a wholesale delegation
would silently drop a compared flag here (or add one at the other three sites).
The § `sharedAliasNoStamp41` / § `arrayElemTdClone42` no-stamp guard is
INHERITED the moment the arm can return a shared object and is added with the
same two predicates the other three sites use.

After A+B, 7 of t60b's 10 index positions match golden exactly (kind, name and
identity; `t60a`'s class-property and body-local `[t_int]` also go
`int_typespec 'pk60::t_int'/LISTED` -> `int_typespec 't_int'/CLONE`, which is
golden's row). The 3 that do not are NOT this law — see residue (2).

## 3. § tdClonePosKey43 + § tdCloneFlagGuard43 — pass 42's findings (a) and (c)

* the clone cache was keyed `{declKey, base}` while `makeTypespec` passes
  `&declSymbol` and `assocIndexTs` passes `&sym` — the SAME pointer for one
  declaration — so a declaration whose ELEMENT and INDEX are the same typedef
  shared ONE clone across two positions where golden mints two. The key now
  carries the POSITION (`std::tuple<const void*, int, const typespec*>`). Not
  cmp-visible and absent from the corpus: hygiene, gated with the rest.
* `tdVecNamedClone42`'s three hand-saved emitter flags are now restored by an
  RAII guard around the re-entrant `makeTypespec` call.

## 4. Measurements (own binaries, idle box; PRE re-measured, not inherited)

PRE reproduces pass 42's committed panel exactly, which is the baseline-validity
check: `r10uvm42tw` residue **3863 / 3581 / 8148 / 3595** and LISTDIRECT
**22/18/22/18 = 80** on a fresh HEAD build.

**THE UVM-4 DOES NOT MOVE AT ALL — and that is the pass's headline measurement,
not a footnote:**

| metric (UVM-4) | HEAD `0d5cf6a` | this pass |
|---|---|---|
| LISTDIRECT | 80 (22/18/22/18) | **80 (22/18/22/18)** |
| `r10uvm42tw` residue | 3863/3581/8148/3595 | **3863/3581/8148/3595** |
| **CPTOTAL** (new, `r10uvm43cp`) | 580 (145/67/299/69) | **580 (145/67/299/69)** |
| the 4 CSV rows | CMP_NOTEQUAL | CMP_NOTEQUAL |

so neither law reaches the four UVM tests: they have no integer-atom or `string`
typedef in a container position that goes through `assocIndexTs` or
`arrayElemTypedefTs15`, and no module/package-level associative array keyed by a
typedef name. That made the full Surelog sweep — not the UVM panel — the
decisive gate, and it came back byte-identical too: **the reach is ZERO on both
corpora** (see the byte verifier below). What the laws are worth is stated
there, honestly, rather than dressed up here.

New metric **CPTOTAL**: the CONTAINER-POSITION census diff against golden
(`r10uvm43cp`, `cp.sh`). It exists because **LISTDIRECT has an unmeasured half**:
it counts referrers FROM THE LISTING OBJECT'S SIDE, so it can only say a direct
reference exists, never what golden puts there instead. That blindness is
exactly what mis-ranked pass 42's residue (see §5(1)).

The pinned panel HELD to the unit, PRE and POST measured on separate workdirs
with the two binaries — which byte-identity (below) makes a consistency check on
the measurement rather than a discovery:

| metric | HEAD `0d5cf6a` | this pass |
|---|---|---|
| `BINDWRONG` | 757 (43/87/521/106) | **757 (43/87/521/106)** |
| `BINDTOTAL` | 1681 (938 extra / 743 miss) | **1681 (938 / 743)** |
| `PAIRTOTAL` | 0 | **0** |
| `IOTOTAL2` / `IOTOTAL` | 3 / 2 | **3 / 2** |
| `INITTOTAL` | 52 | **52** |
| `CTORTOTAL` / `BODYOTHER` | 0 / 435 | **0 / 435** |
| `VARTOTAL` | 0 | **0** |
| `r10uvm23m` | 36 (tf=2 ts=0 var=34) | **36** |
| `r10uvm28a` | 3663/3276/7941/3276 | **3663/3276/7941/3276**, heads identical |
| `r10uvm41ts` | 3827/3555/7974/3569 | **3827/3555/7974/3569** |
| `TSINSTTOTAL` | 1074 | **1074** |

### The gates, on this worktree's own binary

`SLANG_UHDM` pinned to this worktree's `build/slang-uhdm` for every run
(`verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one).

* goldens **23 PASS / 0 FAIL**, with a **NEGATIVE CONTROL on the gate script
  itself**: `SLANG_UHDM=/bin/false` gives **0 PASS / 23 FAIL**, so the pin is
  honoured and the pass is not the script defaulting elsewhere.
* u2r `testflags`: **0 diff lines** over 732 against `results/gate_uhdm2rtlil.csv`
  (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`).
* Surelog both modes: **0 diff lines** over 1589 against
  `results/golden_surelog.csv`, whole row **including DUMP**, so `SLANG_REJECT`
  membership is unchanged by construction and no pinned giant flaked.
* the HEAD half of the byte verifier doubles as a **baseline-validity** check:
  its own CSV is likewise 0 diff lines against the committed baseline.
* **byte verifier — 953 databases, 952 byte-identical, 1 differs, and the 1 is
  `Scoreboard default`**, the row pass 41 measured NONDETERMINISTIC on every
  binary at `--jobs 1` and which is excluded from any identity claim. Both runs
  wrote to the SAME workdir path.

**That last line is the pass's real result and it is stated as a finding, not
buried as a gate:** these two laws are **INERT ON THE ENTIRE CORPUS**, both
modes, all 953 databases. They are measured-correct (§1, §2 — the golden tables
are unambiguous and t60a/t60b reproduce them in seconds) and they remove a
restriction pass 42 explicitly recorded as unmeasured, so the next pass to build
on that gate inherits a right one instead of a wrong one. But nothing converges
and nothing regresses: no test in either corpus has an integer-atom or `string`
typedef in a container position, a chained typedef in one, or a module-level
associative array keyed by a typedef name.

## 5. What is left, MEASURED — pass-44 ranking

**(1) THE `types_t` ELEMENT POSITION IS AN EXTRA OBJECT OF OURS, NOT A NAME
BUG — and this is why pass 42's ranked-#1 was mis-framed.** `r10uvm43cp` on
SimpleUVM:

    golden  642:11-642:26 array_typespec 'types_t'/LISTED elem=<noref> idx=<noref>
    ours    642:11-642:26 array_typespec 'types_t'/LISTED elem=<noref> idx=<noref>
    ours    642:11-642:26 array_typespec 'types_t'/CLONE  elem=int_typespec'uvm_pkg::uvm_action'/LISTED@272:9
    ours    651:13-651:18 array_typespec ''/plain elem=array_typespec'types_t'/LISTED@642:11
    ours    670:13-670:18 array_typespec ''/plain elem=array_typespec'types_t'/LISTED@642:11

`typedef TYPE types_t[$]` (uvm_misc.svh:642, TYPE a class parameter bound to
`uvm_action`). Golden emits ONE `types_t` object with **no Elem_typespec at
all**; we emit a second, CLONE-tagged one whose element is the `uvm_action`
LISTING object (the whole of LISTDIRECT's `int_typespec` row), plus two more
`array_typespec`s wrapping the listing `types_t` for the two `types_t types;`
locals. So the residue is THREE EXTRA OBJECTS and a missing "no element",
not a qualified-vs-bare name — and widening the kind gate (correct as a law,
§1) cannot touch it. Golden's 37+5 `uvm_action` clones are all `io_decl` /
`int_var` referrers, i.e. the FORMAL and SCALAR positions, never a container.

**(2) THREE LISTING OBJECTS WE NEVER EMIT, and the unsupported-construct
message points straight at them.** After §2, t60b's remaining 3 mismatched
index positions are `[m_int]`, `[m_byte]` and `[p_str]`, and the reason is not
the index rule: `sharedAliasTs` returns null because **no listing object
exists** — our emitter reports `typedef target: PredefinedIntegerType` as an
UNSUPPORTED CONSTRUCT and emits no typespec for a MODULE-scope `typedef int` /
`typedef byte`, nor for a PACKAGE `typedef string`. Golden lists all three
(`int_typespec 'm_int' LISTED fanin=9`, `byte_typespec 'm_byte' LISTED`,
`string_typespec 'pk61::p_str' LISTED`). A missing object is a bigger cmp
difference than a mis-named one, and this arm makes it reproducible in 3 lines.
The rejecting site is `TypeEmit.cpp:9820` — the MODULE typedef-listing loop
accepts `PackedArrayType`/`ScalarType` (plus the earlier enum/struct arms) and
`noteUnsupported`s everything else, so `typedef int` at module scope never
reaches `typedefTs` and every downstream registry lookup for it must fail.
**Reach — CORRECTED BY THE VERIFIER, and materially larger than first written:
running this README's own grep at the Surelog corpus root gives 93 atom-typedef
declarations across 52 files (tests 10 + third_party/tests 42), plus 1 more file
in uhdm2rtlil — NOT the 44 across 32 originally recorded. Direction unchanged:
ranked-#1-by-reach is if anything stronger. Original (understated) figure: 44 across 32
files** (`grep -rhoE '^[[:space:]]*typedef[[:space:]]+(int|byte|shortint|longint|integer|time|string)[[:space:]]+[A-Za-z_]' tests third_party/tests`)
— so unlike this pass's two laws the SHAPE is present in the corpus; what is
absent is only the container-position use of it. That makes this the ranked
first item by reach, not just by size.

**(3) TWO MORE PACKAGE-SCOPE GAPS the arms exposed, both reproducible:**
a package-level FIXED UNPACKED ARRAY variable is emitted by golden and **dropped
entirely by us** (`t_int e_int[4];` in a package: no variable in our database at
all, for every base kind including `bit`), and a class PROPERTY whose type is an
unpacked array over a NON-VECTOR typedef is rejected (`class property type:
FixedSizeUnpackedArrayType`). The first is why t60a's ELEMENT half had to be
re-measured at module scope in t60b.

**(4) A FIFTH INLINE COPY OF THE INDEX RULE, at `ParamEmit.cpp:19783`** — the
`$unit`/parameter-scoped `array_var` path, same three keyword arms, same missing
registry arm, and it additionally does `its->Instance(up)`. NOT measured (no arm
reaches it yet), so it is recorded rather than changed: pass 41's §4(2) warning
about generalising an unmeasured site applies verbatim.

**(5) the `string_typespec` INSTANCE residue** — carried from pass 42 unchanged
(TSINSTTOTAL 1074; golden 684/0, 656/14, 1392/12, 656/0 vs ours 594/168,
559/194, 918/532, 559/180; golden HAS 26 class-instanced rows so the rule is not
"never the class").

**(6) CPCLASS = 25 rows (8/5/7/5), new and cmp-relevant.** An array of class
handles: golden's ELEMENT typespec is a `class_typespec` NAMED after the class
and spanned at the declaration's TYPE text; ours is UNNAMED and spanned at the
declarator (`elem=class_typespec'uvm_component'/plain@120:31` vs
`class_typespec'<unnamed>'/plain@121:3`). `cpclass.sh`.

**(7) 23 EXTRA empty `array_typespec`s on SimpleUVM** (`elem=<noref>
idx=<noref>`, unspanned) — a pure object-count residue inside CPTOTAL, worth an
identification pass before anything else in CPTOTAL is attributed.

**(8)-(12) carried, unchanged and untouched**: the MODULE-IMPLICIT-NET arm
(owns `BINDTOTAL`'s disclosed +4; binding both views is a wash because
`r10uvm28m` keys on a SET of actuals); `BARE -> SELF` 438 rows, homogeneous PER
ROUTINE; `BINDWRONG`'s 342 owner-attribution and 82
parameter-vs-folded-constant rows; the `IOTOTAL2`=3 POPULATION row; the MODULE
arm of § `classKeyTsScopeOwner35`; the socket sharing residue; the clone-SHARING
residue (one clone per typedef per VIEW where golden mints one per DECLARATION);
the `uvm_severity` enum span; `INITTOTAL`-52; t40a; `r10uvm23m` var=34; t36b;
t33d.

## 6. Reproduce

    tools/probe/r10uvm43repro/probebuild.sh r10uvm43cp r10uvm42tw r10uvm41ts r10uvm28a ...
    tools/probe/r10uvm43repro/gold.sh   t60a|t60b <outdir> [binary]
    tools/probe/r10uvm43repro/uvm4.sh   <out.csv> <workdir> [binary]
    tools/probe/r10uvm43repro/res.sh    <sweep-workdir> <tag> [probe]
    tools/probe/r10uvm43repro/listdirect.sh <tag>
    tools/probe/r10uvm43repro/ldrows.sh <tag> [test]     # WHICH objects, not how many
    tools/probe/r10uvm43repro/cp.sh     <sweep-workdir> <tag> <test> [filter]
    tools/probe/r10uvm43repro/cpclass.sh <tag>
    tools/probe/r10uvm43repro/panel.sh  <sweep-workdir>
    tools/probe/r10uvm43repro/tsinst.sh <sweep-workdir>
    tools/probe/r10uvm43repro/gate.sh   goldens|u2r|sl|slbin ...
    tools/probe/r10uvm43repro/byteverify.sh <wd> <head-bin> <csv-head> <csv-post>

## VERIFIER CORRECTIONS (applied at integration, pass 43)

CONFIRMED verdict, four corrections, none affecting it:

1. REACH of ranked (1) was UNDERSTATED — 93 atom-typedef declarations across 52
   files, not 44 across 32 (corrected in place above).
2. `listdirect.sh`'s header carried PASS 42's movement STALE ("HEAD is 224
   (+168), this pass 80 (+24)"). At pass 43 HEAD and POST are BOTH 80 — this
   pass is corpus-inert and made NO LISTDIRECT movement. Corrected in the
   script, because a future pass would otherwise have credited pass 43 with a
   224->80 drop it did not make. RE-MEASURE, DO NOT INHERIT A NUMBER.
3. §5(7) UNDER-RANKS ITSELF: the extra unspanned empty `array_typespec` rows are
   98/23/94/23 = **238 across the UVM-4**, not 23 in total.
4. THE ELEMENT HALF OF THE WIDENED KIND GATE IS UNWITNESSED BY THE ARMS — the
   same unmeasured-half trap this campaign keeps hitting, so it is named here
   rather than left implied. Golden t60b has ZERO container-ELEMENT typespec
   rows (every array_typespec has `elem=<noref>`), and golden t60a's only
   element rows are 2x int CLONE + 2x bit CLONE + 4x unnamed — so NO ARM shows
   golden's element choice for byte/shortint/longint/integer/time/string, nor
   for a CHAINED typedef. Our own element rows in t60a are IDENTICAL HEAD vs
   POST (the makeTypespec posKey=0 path never fires in either arm). So §1's
   per-kind table is AN INDEX-POSITION MEASUREMENT; the kind widening and the
   chain exclusion are applied at the ELEMENT position purely BY INFERENCE.
   HEAD would have cloned a chained bit typedef's element where POST binds the
   listing object, with no golden witness either way. Corpus-inert today
   (953/953 byte-identical), so no risk now — but the element half belongs on
   the UNMEASURED list beside real/shortreal/union/class-handle, and a future
   pass must witness it before relying on it.

Also cleared by the verifier, not a defect: the new registry arm in
`emitDynArrayVar` returns before the VpiSigned block, which could have dropped a
compared flag for a signed atom-typedef index — measured on t60b, our clone for
`[p_int]` carries vpiSigned:1, same as golden's.
