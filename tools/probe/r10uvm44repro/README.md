# r10uvm44 — UVM pass 44

Pass 43's ranked #1 was **"the three missing listing objects"**, ranked FIRST BY
REACH on the strength of a corrected figure — *93 atom-typedef declarations
across 52 files* — and explicitly contrasted with pass 43's own corpus-inert
laws: *"unlike this pass's two laws the SHAPE is present in the corpus."*

It is not. **The reach figure was itself a mis-measurement, and this pass's
headline result is that finding, not the code.** The two laws below are
measured-correct against golden, close the last open member of a five-copy
family, and are **INERT ON THE ENTIRE CORPUS — 952/953 databases byte-identical
both modes and both corpora, the one difference being the `Scoreboard` row whose
flake this pass re-established with a control instead of inheriting the claim
(§4).**

## 0. MEASURE THE MEASURER — why ranked #1 could not move anything

The reach came from

    grep -rhoE '^[[:space:]]*typedef[[:space:]]+(int|byte|shortint|longint|integer|time|string)[[:space:]]+[A-Za-z_]' tests third_party/tests

and that regex does not select the shape the law needs. `tools/probe/
r10uvm44repro/atomtd.py` selects it — `typedef <atom-keyword> <name>;` with **no
dimensions** (so the canonical kind really is `PredefinedIntegerType` /
`StringType` / `FloatingType` / `CHandleType` / `EventType`), in files a
SystemVerilog front end reads, **with the ENCLOSING SCOPE reported**, because the
scope is the whole distinction between the arm that already existed (package)
and the arm that did not (module):

| | pass 43's grep | the actual shape (`atomtd.py`) |
|---|---|---|
| files | 52 | **23** |
| declarations | 93 | **28** |
| at MODULE scope — the arm that was missing | (not asked) | **0** |
| at PACKAGE scope, of a kind with no arm (`string`/`real`/`shortreal`/`chandle`/`event`) | (not asked) | **0** |
| at `$unit` scope | (not asked) | 27 |
| inside a CLASS | (not asked) | 1 |

What the grep counted instead: **ARRAY typedefs** (`typedef int unsigned
ASSIGN_VADDR_RET_T[CNT];` in DefaultPatternModule / ArrayExprFuncArg /
DefaultPatternInt / FuncRetArray, `typedef int triple [1:3];` in
UnpackedTypespec — canonical kind `FixedSizeUnpackedArrayType`, a different arm
that already worked and where all four tests are already `CMP_EQUAL`),
`$unit`-scope and class-scope typedefs (different loops again), and **C/C++
headers** (`dhry.h`, `f2c.h`, `slu_mt_*defs.h`, `usbdev.h`, `virtio.cpp`, …)
that are never compiled as SystemVerilog.

And the 27 `$unit` ones cannot move a verdict either: every test that reads them
is `SLANG_REJECT` or worse — `NameCollisionBind`, `UnitClass`, `ClassFuncProto`,
`TNocBadType`, `SplitFile`, `AmiqEth` all `SLANG_REJECT`; the `Google` aggregate
is `SLANG_REJECT`/`TIMEOUT`; the `Verilator` aggregate is `SLANG_REJECT`; and
`uhdm2rtlil/EnumBases` is `SLANG_REJECT`.

**THE LESSON, one level up from pass 43's own:** pass 43 taught that a one-sided
census cannot say whether golden's side of a position is populated, and built
CPTOTAL for it. It then ranked its successor with **a grep whose selectivity
nobody checked** — no scope filter, no kind filter, no file-type filter. A
POPULATION count is a measurement and needs a measurer just as much as a
position census does. **The cheapest check is the byte verifier: run it and see
whether anything moves.**

## 1. § atomTdListing44 — the law, measured on both scopes and every spelling

Arm `t61a` carries one typedef per non-aggregate keyword kind at **module** scope
and at **package** scope, plus a CHAINED atom typedef and one with **no user at
all**, and `r10uvm44ls` prints each scope's `vpiTypedef` vector as the ordered
`(kind, VpiName)` sequence + its SIZE — which is exactly what uhdm-cmp reads
(`r=1 failLhs=<container>` is a vector SIZE mismatch).

    scope                    golden   HEAD   POST
    module_inst ''/def          31      12     31
    module_inst 'work@dut62'/top 31      12     31
    package 'pk62'/def          14      10     15
    package 'pk62'/top          15      10     15

The 19 module-view entries HEAD never emitted are the 14 module typedefs (`int`,
`int unsigned`, `byte`, `shortint`, `longint`, `integer`, `time`, `string`,
`real`, `shortreal`, `chandle`, `event`, the CHAIN, the UNUSED one) plus the 5
package ones the module's import listing republishes (`q_str`, `q_real`,
`q_sreal`, `q_chandle`, `q_event` — the package arm existed but only for
`PredefinedIntegerType`). The emitter named the deficit itself:
`slang-uhdm: unsupported constructs encountered: typedef target:
PredefinedIntegerType / StringType / FloatingType / CHandleType / EventType`,
now silent on this arm.

Both halves are WITNESSED, not inferred — one golden row per spelling, at both
scopes. Two rows worth naming:

* golden **lists a typedef with no user anywhere** (`byte_typespec:m_unused`), so
  the listing is a declaration table, not a use table;
* the CHAIN takes the **target atom's kind under its own bare name**
  (`typedef m_int m_chain` -> `int_typespec:m_chain`), which is what the shared
  `makeTypespec` already produces — no chain-specific arm needed. Contrast
  § `tdChainNoClone43`, which is about CLONING at a container position and is a
  different question.

**RESIDUE, deliberately not fixed (see §5(2))**: golden's package DEF listing
OMITS the atom chain (14, no `q_chain`) while its TOP listing carries it (15).
Ours lists it in both. That is a PRE-EXISTING extra at HEAD, not a regression
here, and it is the atom spelling of a def-omission rule the vector arm already
implements (`ParamEmit.cpp:17606`, `continue; // no def-listing entry`).

## 2. § assocIdxSiteFive44 — the five-copy family, CLOSED

Pass 43 found a FOURTH copy of the associative-INDEX rule that never consulted
the typedef registries, fixed it, and **recorded a fifth at
`ParamEmit.cpp:19783` as unmeasured rather than changing it.** It is measured
now: arm `t60a`'s package `pk60` declares one `int i_<k>[t_<k>];` per base kind
at **package** scope, which is exactly `emitPkgArrayVar`'s index block, and
`r10uvm43cp` reads golden against HEAD as fifteen rows of

| written index | golden | HEAD |
|---|---|---|
| `[t_int]` | `int_typespec 't_int'`/CLONE@28:11 | `int_typespec '<unnamed>'`@78:13 |
| `[t_byte]` | `byte_typespec 't_byte'`/CLONE | `byte_typespec '<unnamed>'`@79:14 |
| `[t_sint]` | `short_int_typespec 't_sint'`/CLONE | `short_int_typespec '<unnamed>'`@80:14 |
| `[t_lint]` | `long_int_typespec 't_lint'`/CLONE | `long_int_typespec '<unnamed>'`@81:14 |
| `[t_integer]` | `integer_typespec 't_integer'`/CLONE | `integer_typespec '<unnamed>'`@82:17 |
| `[t_uint]` | `int_typespec 't_uint'`/CLONE | `int_typespec '<unnamed>'`@83:14 |
| `[t_time]` | `time_typespec 't_time'`/CLONE | `time_typespec '<unnamed>'`@84:14 |
| `[t_str]` | `string_typespec 't_str'`/CLONE | `string_typespec '<unnamed>'`@88:13 |
| `[t_log1]`, `[t_reg4]` | `logic_typespec 't_log1'` / `'t_reg4'`/CLONE | `logic_typespec '<unnamed>'` |
| `[t_bit8]` | `bit_typespec 't_bit8'`/CLONE | **`logic_typespec`** `'<unnamed>'`@85:14 |
| `[t_enum]` | `enum_typespec 'pk60::t_enum'`/LISTED | **`logic_typespec`** `'<unnamed>'`@89:14 |
| `[t_pstr]`, `[t_ustr]` | `struct_typespec 'pk60::t_pstr'` / `'t_ustr'`/LISTED | **`logic_typespec`** `'<unnamed>'` |
| `[t_chain]` | `bit_typespec 'pk60::t_chain'`/LISTED | **`logic_typespec`** `'<unnamed>'`@92:15 |

— **the same table as site four**, so this is one rule with five copies, not five
rules. The bottom five rows are WRONG KIND as well as unnamed and `VpiType` and
`VpiName` are both compared. POST reproduces golden's whole column: kind, name
and identity, every row (`gold.sh t60a` + `r10uvm43cp`, seconds).

Same construction as site four: **prepend the registry arm, keep the keyword
arms as the FALLBACK** (this site's `predefIntTypespec` path differs from
`assocIndexTs`, so a wholesale delegation would move a compared field at one
site or the other), and inherit the § `sharedAliasNoStamp41` /
§ `arrayElemTdClone42` no-stamp guard. Here that guard covers **TWO** stamps,
not one — this site also did `its->Instance(up)`, which would have re-Instanced a
shared listing object at the declaring package. NEVER MUTATE A SHARED OBJECT:
guarded on POINTER IDENTITY against both registries plus the clone set
(`isSharedAliasTs` / `isTdVecClone42`), never on a canonical kind.

**The invariant now holds at every site, by grep.** `grep -n 'Index_typespec'
src/*.cpp` gives four writers — `UhdmExporter.cpp:1284`, `TaskFuncEmit.cpp:1193`,
`TypeEmit.cpp:14454`, `ParamEmit.cpp:19873` (plus `TypeEmit.cpp:4416`, which
COPIES an existing ref). The first two take their object from `assocIndexTs`
(registry-first by construction, and it serves `emitAssocDims`' outer and inner
dimension, `UhdmExporter.cpp:2052` and `TaskFuncEmit.cpp:1090`); the third is
§ `assocIdxSiteFour43`; the fourth is this pass. No open-coded index site
remains.

## 3. New metric — LSTOTAL, and why a third census was needed

`r10uvm44ls` / `ls.sh`. LISTDIRECT counts referrers **from the listing object's
side**; CPTOTAL asks **what object sits in a container position**. Both are blind
to an object **that does not exist** — nobody refers to it and it occupies no
position — and pass 43's ranked #1 was exactly that kind of deficit. The listing
vector is the only place a missing entry shows, and it is the first thing
uhdm-cmp reads.

    LSTOTAL (entry-level, UVM-4)   811 = 2 / 0 / 408 / 401   (scope-level 11)

Scope-level 11 out of ~5 200-7 000 listing vectors per test: the listings are
almost all right, and the residue is **concentrated in two scopes per test**.
That concentration is what makes §5(1) below the ranked first item for pass 45 —
and unlike pass 43's ranked #1, it is measured PRESENT, on a test in the corpus.

## 4. Measurements (own binaries, idle box; PRE re-measured, NOT inherited)

PRE reproduces pass 43's committed panel exactly on a fresh HEAD build, which is
the baseline-validity check:

| metric (UVM-4) | pass 43 committed | HEAD re-measured | this pass |
|---|---|---|---|
| `r10uvm42tw` residue | 3863/3581/8148/3595 | **3863/3581/8148/3595** | **unchanged** |
| `r10uvm41ts` | 3827/3555/7974/3569 | **3827/3555/7974/3569** | **unchanged** |
| `r10uvm28a` | 3663/3276/7941/3276 | **3663/3276/7941/3276** | **unchanged** |
| `LISTDIRECT` | 80 (22/18/22/18) | **80 (22/18/22/18)** | **unchanged** |
| `CPTOTAL` | 580 (145/67/299/69) | **580 (145/67/299/69)** | **unchanged** |
| `LSTOTAL` (new) | — | **811 (2/0/408/401)** | **unchanged** |
| the 4 CSV rows | CMP_NOTEQUAL | CMP_NOTEQUAL | CMP_NOTEQUAL |

Everything is "unchanged" for one reason and it is stated as the result, not
hidden as a gate: **both laws are corpus-inert**, so the POST databases are
byte-identical to HEAD's and every derived metric is identical by construction.
The pinned panel (`BINDWRONG` 757, `BINDTOTAL` 1681 = 938 extra / 743 miss,
`PAIRTOTAL` 0, `IOTOTAL2` 3, `IOTOTAL` 2, `INITTOTAL` 52, `CTORTOTAL` 0,
`BODYOTHER` 435, `VARTOTAL` 0, `r10uvm23m` 36, `TSINSTTOTAL` 1074, `CPCLASS` 25)
therefore holds to the unit as well, and byte identity makes that a consistency
check on the measurement rather than a discovery.

### The gates, on this worktree's own binary

`SLANG_UHDM` pinned to this worktree's `build/slang-uhdm` for every run
(`verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one).

* goldens **23 PASS / 0 FAIL**, with a **NEGATIVE CONTROL on the gate script
  itself**: `SLANG_UHDM=/bin/false` gives **0 PASS / 23 FAIL**.
* u2r `testflags`: **0 diff lines** over 732 vs `results/gate_uhdm2rtlil.csv`
  (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`).
* Surelog both modes: **0 diff lines** over 1589 vs `results/golden_surelog.csv`,
  whole row INCLUDING `DUMP`, so `SLANG_REJECT` membership is unchanged by
  construction and no pinned giant flaked.
* the HEAD half of the byte verifier is likewise **0 diff lines** against the
  committed baseline — a baseline-validity check.
* **byte verifier, law 1 alone: 953 databases, 953 byte-identical.** Both runs
  wrote to the SAME workdir path.
* **byte verifier, final build (both laws): 953 databases, 952 byte-identical, 1
  differs, and the 1 is `Scoreboard default`** — the excluded row, with a
  CONTROL run this pass rather than an inherited claim (below).

### The Scoreboard exclusion, RE-ESTABLISHED — and pass 41's figure corrected

Pass 41's statement is that `Scoreboard` is nondeterministic *"on every binary
even at `--jobs 1`"*. **At `--jobs 1` it did not reproduce here:**
`r10uvm41repro/detcheck.sh Scoreboard 3` on the POST binary gave **three
identical hashes** (`ebe12c0a64f79822` ×3). So the inherited exclusion was, on
this box today, unsupported at the concurrency it was stated for — and a
byte-verifier difference cannot be waved away with a claim that does not
reproduce.

The flake is **JOBS-DEPENDENT**, which is what MEMORY.md's emitter-
nondeterminism note predicts (SourceLocation compares across macro buffers flip
under PARALLEL PARSE), and `byteverify.sh` sweeps at `--jobs 4`. New driver
`detcheck4.sh` samples at the concurrency the measurement actually ran at, with
**ONE binary**, which is the correct control for a two-binary byte difference:

    detcheck4.sh Scoreboard 4 4 /tmp/r10uvm44_head_bin
      run1 jobs=4 ebe12c0a64f79822
      run2 jobs=4 ebe12c0a64f79822
      run3 jobs=4 e6b9b552e9434398
      run4 jobs=4 e6b9b552e9434398

**The HEAD binary ALONE produces two distinct hashes at `--jobs 4`**, and one of
them is the hash the POST binary produced at `--jobs 1` — so both binaries
produce both hashes and the single byte difference is PRE-EXISTING flake, not a
change of this pass's. A DETERMINISM CLAIM MUST BE MADE AT THE CONCURRENCY THE
MEASUREMENT RAN AT.

**Both laws were gated separately**: law 1 got its own goldens + u2r + full
both-modes byte verifier before law 2 was written; the final build was then
re-gated in full.

## 5. What is left, MEASURED — pass-45 ranking

**(1) RANKED FIRST, AND UNLIKE PASS 43'S #1 THE SHAPE IS PRESENT AND THE
POSITION IS POPULATED ON A LIVE CORPUS TEST.** On `SimpleUVM`, `r10uvm44ls`:

    golden   module_inst ''/def            n=123      class_defn 'work@env' n=123
    golden   module_inst 'work@top'/top    n=123
    ours     module_inst ''/def            n=89       class_defn 'work@env' n=123
    ours     module_inst 'work@top'/top    n=89

**Golden's TOP-MODULE type table is BYTE-IDENTICAL, as an ordered `(kind,name)`
sequence, to golden's `$unit` CLASS table — and OUR class table already
reproduces golden's exactly (123/123, zero diff).** So the module listing is a
RE-PUBLICATION we are not doing, not a table we build wrongly:

* 34 entries missing per view, ×2 views: `class_typespec:this_type` ×26,
  `:this_subtype` ×5, `:type_id` ×2, `:super_type` ×1 — the class-scope typedefs
  the `uvm_*_utils` macros expand into, which golden publishes into the module
  table UN-prefixed and NOT deduplicated;
* plus 3 entries of ours in the wrong POSITION (`uvm_pkg::uvm_heartbeat_cbs_t`,
  `uvm_pkg::uvm_mem_cb_iter`, `uvm_pkg::uvm_table_printer_knobs`) — so 37 of the
  123 positions disagree, and the order is compared.

Only `work@env` carries the 123-entry table (`work@mailbox`/`work@semaphore` 0,
`work@process` 1), i.e. it is the FIRST `$unit` class and Surelog hangs the whole
`$unit` type table off it and off the top module. `LSTOTAL` 408 on `SeqDriver`
and 401 on `SimpleUVM` is almost entirely this; `BuildUVMPkg` 2 and `Scoreboard`
0 have no `$unit` class. **Check before building: whether the re-publication is
the DEF table, the TOP table or a per-view one, and what `BuildUVMPkg`'s 2 are.**

**(2) THE PACKAGE DEF LISTING'S ATOM CHAIN** — `t61a` measures golden def=14
(no `q_chain`) vs top=15 (with it); ours lists it in BOTH, a PRE-EXISTING extra.
The vector spelling of the same rule is already implemented
(`ParamEmit.cpp:17606`, `continue; // no def-listing entry`, `topView`
republishes the DEF object); the atom spelling reaches the new arm instead and
has no such gate. Identified and NOT landed here because it REMOVES a listing
object and its corpus reach is unmeasured — `associdx.py` reports **zero**
package-scope container declarations of any kind in the corpus, which is a hint
that it is inert too, but that is not the same measurement. Measure it, or just
run the byte verifier, before landing.

**(3) THE PACKAGE FIXED UNPACKED ARRAY IS STILL DROPPED ENTIRELY** and this pass
localised the site: `emitPkgArrayVar`'s `switch (ct.kind)` accepts `QueueType` /
`DynamicArrayType` / `AssociativeArrayType` and `return false`s on
`FixedSizeUnpackedArrayType`. `r10uvm43cp` on `t60a` counts golden 96
`array_typespec`s vs our 47 and the 49 missing are these. Same function as §2,
one arm over.

**(4) THE UNMEASURED LIST, unchanged and NOT settled**: the ELEMENT half of pass
43's widened kind gate (golden's arms have ZERO container-ELEMENT typespec rows;
`t61a` does not add any either, since it is a LISTING arm) and
`real`/`shortreal`/`union`/class-handle in either CONTAINER position. Note the
distinction this pass makes: `t61a` witnesses those kinds as **LISTING** objects,
which is a different question from what a container position BINDS. Do not let
§1 above be read as closing §4.

**(5)-(9) carried, unchanged and untouched**: the `types_t` ELEMENT position
(three extra objects of ours, the whole of LISTDIRECT's `int_typespec` row —
still the ranked item whose fix REMOVES objects); the 238-row unspanned empty
`array_typespec` family (98/23/94/23); the module-implicit-net arm (owns
`BINDTOTAL`'s disclosed +4, a wash because `r10uvm28m` keys on a SET of
actuals); `BARE -> SELF` 438 rows, homogeneous PER ROUTINE; `BINDWRONG`'s 342
owner-attribution and 82 parameter-vs-folded-constant rows; the `IOTOTAL2`=3
POPULATION row; the `string_typespec` instance residue `TSINSTTOTAL` 1074
(golden HAS 26 class-instanced rows); `CPCLASS` 25; the MODULE arm of
§ `classKeyTsScopeOwner35`; the socket sharing residue; the clone-SHARING
residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=34; t36b; t33d.

**(10) A DRIVER DEFECT WORTH REMEMBERING.** `clone43.sh` re-namespaces pass 43's
drivers by `sed s/r10uvm43/r10uvm44/g`, which also rewrote the PROBE BINARY names
(`/tmp/r10uvm43_r10uvm43cp` -> `/tmp/r10uvm44_r10uvm44cp`, a file that does not
exist). `cp.sh` then reported **`SimpleUVM golden=0 ours=0 diff=0`** — *a driver
that cannot find its probe reports PERFECTION.* Caught because a hand-run of the
probe on the same golden printed 493 lines. Fixed in `cp.sh` with the reason
recorded there; `ls.sh` keeps its own name legitimately. Every driver in this
directory now names its probe with the probe's BIRTH pass and only the /tmp
namespace prefix moves.

## 6. Reproduce

    tools/probe/r10uvm44repro/clone43.sh                       # drivers, then fix cp.sh's V=
    tools/probe/r10uvm44repro/probebuild.sh r10uvm44ls r10uvm43cp r10uvm42tw r10uvm41ts r10uvm28a
    tools/probe/r10uvm44repro/atomtd.py   ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests ~/git-repos/uhdm2rtlil/test
    tools/probe/r10uvm44repro/associdx.py <same roots>
    tools/probe/r10uvm44repro/gold.sh     t61a <outdir> [binary]
    tools/probe/r10uvm43repro/gold.sh     t60a|t60b <outdir> [binary]
    tools/probe/r10uvm44repro/ls.sh       <sweep-workdir> <tag> [test ...]
    tools/probe/r10uvm44repro/cp.sh       <sweep-workdir> <tag> <test> [filter]
    tools/probe/r10uvm44repro/res.sh      <sweep-workdir> <tag> [probe]
    tools/probe/r10uvm44repro/listdirect.sh <tag>
    tools/probe/r10uvm44repro/csvdiff.sh  <baseline.csv> <new.csv>
    tools/probe/r10uvm44repro/gate.sh     goldens|u2r|sl|slbin ...
    tools/probe/r10uvm44repro/byteverify.sh <wd> <head-bin> <csv-head> <csv-post>
    tools/probe/r10uvm44repro/detcheck4.sh <Test> <N> <jobs> [binary]
