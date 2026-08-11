# r10uvm45 — UVM pass 45

**ONE law. `LSTOTAL` 811 -> 3, scope-level 11 -> 3 — the headline metric
essentially CLOSED.** `SeqDriver` 408 -> 0, `SimpleUVM` 401 -> 1, `BuildUVMPkg`
2 (untouched, and not a listing residue), `Scoreboard` 0. Every other metric in
the panel is unchanged to the unit, and the corpus reach is exactly the two
target tests in both modes — byte verifier on the final binary: **953 databases,
949 byte-identical, exactly 4 differ, and all 4 are the targets.**

The law is one rule with **four cells**. TWO came from the corpus (a module's
`$unit` import on `SimpleUVM`, a module's BODY import on `SeqDriver`); the other
TWO came from arm `t62a`, built inside this pass — and one of those **refuted the
pass's own first implementation**, which is why the gate was run three times.

## 0. The three checks the handoff demands BEFORE ranking — answered up front

Pass 43 and pass 44 were both ranked onto their targets by a mis-measured
population. The rule that bought: *(a) confirm the SHAPE with a selective
census, (b) confirm the tests holding it are COMPARABLE, (c) confirm GOLDEN's
side of the position is populated.* For this pass's item:

| | answer | how |
|---|---|---|
| (a) shape present | **YES** — `SimpleUVM`'s and `SeqDriver`'s top modules each import a class-carrying package; 34 entries missing per view x 2 views + 3 misplaced | `r10uvm44ls` + `modcls.sh`, below |
| (b) tests comparable | **YES** — `SeqDriver` and `SimpleUVM` are `CMP_NOTEQUAL` in BOTH modes (not `SLANG_REJECT`, not `TIMEOUT`, not `DEFERRED`); 4 of the 7 comparable UVM-4 rows | `results/golden_surelog.csv` |
| (c) golden's side populated | **YES, and byte-identically to a table we already build** — golden's module listing IS golden's `$unit` class listing as an ordered `(kind,name)` sequence (123/123), and our class listing already equals golden's | `modcls.sh SimpleUVM`, five pairwise diffs |

## 1. § modulePublishesPackageClasses45

`ModuleEmit.cpp` (`emitImportArtifacts` recording site + the pass itself),
`UhdmExporter.cpp` design-final, `include/UhdmExporter.h`.

`CompileHelper::importPackage` does not care what kind of scope it imports INTO,
so a scope that imports a package gains that package's **class-name DataTypeMap
keys** — inserted BEFORE the package's own entries, `writeDataTypes` then
walking the merged `std::map` in KEY order and pushing each value **deduped by
object identity**. That rule was implemented for an importing PACKAGE
(§ `importPublishesPackageClasses24`) and for an importing CLASS
(§ `classInheritsContainerImports23`). It was never implemented for a MODULE or
an INTERFACE.

### Why 44 passes did not see it

    golden   module_inst ''/def  n=123   |  class_defn 'work@env'  n=123
    golden   module_inst 'work@top'/top  n=123
    ours     module_inst ''/def  n=89    |  class_defn 'work@env'  n=123
    ours     module_inst 'work@top'/top  n=89

Golden's three sequences are byte-identical to each other and **our class
sequence already equals golden's, entry for entry, in order**. So this was never
a table we build wrongly — it is a **RE-PUBLICATION we were not doing**.
`LISTDIRECT` counts referrers from the listing object's side and `CPTOTAL` asks
what sits in a container position; **both are blind to an object that is absent
from a vector but present and referenced everywhere else.** `LSTOTAL`, minted at
pass 44, is the only census that can see it — and the listing vector is the
FIRST thing uhdm-cmp reads.

`modcls.sh` is the third projection and the one that decides the question: the
scope-level `ls` dump puts 123 entries on one line, and the `-e` dump prefixes an
INDEX so one insertion shifts every later line (which is why the deficit read as
`408` and `401` rather than `34`). `modcls.sh` emits the bare ordered sequences
and diffs them pairwise.

### The four cells

| cell | witness | answer |
|---|---|---|
| MODULE, `$unit` import | `SimpleUVM` (corpus) | 34 entries missing/view: `this_type` x26, `this_subtype` x5, `type_id` x2, `super_type` x1 — plus 3 of ours MOVED to the class key that reaches them first (`uvm_heartbeat_cbs_t` at key `uvm_callbacks`, `uvm_mem_cb_iter` at `uvm_callback_iter`, `uvm_table_printer_knobs` at `uvm_printer_knobs`) and dropped at their own name. Names stay **BARE**. |
| MODULE, BODY import | `SeqDriver` (corpus) | the same 34 objects, named `adpcm_pkg::this_type` — § 24 already requalified them for `adpcm_pkg`, which is why this pass must run AFTER it. golden 125 = SimpleUVM's 123 + 2 `import_typespec`s. |
| **KEY COLLISION** | **`t62a` — REFUTED THIS PASS'S FIRST IMPLEMENTATION** | see below |
| **INTERFACE arm** | **`t62a` — present, and missing from the first implementation** | see below |

**The one way this merge can REMOVE something golden keeps**, stated because the
map is a lossy structure: two entries the scope ALREADY lists that share a base
name now collapse to one, where the old `stable_sort` kept both. That is
faithful to `writeDataTypes` (one `std::map`, one value per key) but it is a
DROP, so it needs a guard rather than an argument — and the byte verifier is
that guard: **only 4 of 953 databases changed at all**, so no listing anywhere in
either corpus lost an entry to it, and the two that did change reproduce golden's
count exactly (123/123 and 125/125, both views, `comm` empty both ways). An
UNNAMED entry has no DataTypeMap key at all and is kept out of the map entirely —
otherwise every unnamed entry would collide at `""` and all but one would vanish.

**Two things the law never does**: it never REQUALIFIES a name
(`writeDataTypes` qualifies only for a PACKAGE parent, and golden's SimpleUVM
entries are bare precisely because no package imported `uvm_pkg` there), and it
never touches `vpiInstance` / `vpiParent` / any field of a typespec — only the
scope's own vector. `writeModule` has no counterpart to `writePackage`'s
unconditional `tp->Instance(p)` re-stamp and golden agrees (`this_type` stays
`@design`, the cell § `classKeyTsScopeOwner35` reads), so re-stamping here would
move a compared field on objects shared with every other listing. **NEVER MUTATE
A SHARED OBJECT** is satisfied structurally: nothing is mutated at all.

## 2. Arm t62a — and the cell that refuted my own first version

The first implementation merged the class keys into the existing listing with a
`stable_sort` and kept BOTH sides of a key collision, on the argument that *an
extra is safer than a drop*, and it declared that choice as an unmeasured half
because no UVM-4 golden has a collision. **That is exactly the kind of
"unmeasured half" the campaign says to go and measure, so I built the arm.**

`t62a` puts a CLASS named `kname` in `pa63`, a TYPEDEF named `kname` in `pb63`,
wildcard-imports both into `m63` (never USING the name, so the ambiguity is
legal), and adds an `i63` interface and a `p63` program with the same import:

    golden  module_inst 'u_m'/def n=6 | pa63::a_plain | pb63::b_plain
                                      | this_type | this_type | imp:pa63 | imp:pb63
    HEAD    module_inst 'u_m'/def n=7 |  ...  | pb63::kname | imp:pa63 | imp:pb63
                                                ^^^^^^^^^^^ golden does NOT list it

**It is ONE `std::map`: the class key WINS and the same-named typedef is gone.**
The conservative merge gave seven entries and one extra, so it was replaced by
the map — which is also the faithful model of `writeDataTypes` and the same
construction § 24 uses.

And the interface half:

    golden  interface_inst ''/def   n=4 | pa63::a_plain | this_type | this_type | imp:pa63
    golden  interface_inst 'u_i'/def n=4 | (identical)
    HEAD    interface_inst ''/def   n=2 | pa63::a_plain | imp:pa63
    HEAD    interface_inst 'u_i'/def n=2 | (identical)

So an interface publishes the keys too. Fixing the def view alone then left
`u_i` at 2 — because **the elab interface view COPIES the def view's vector at
EMISSION time** (`ModuleEmit.cpp` "the elab HOME view lists the def view's
typedef/import typespecs"), so a design-final rewrite of the def view cannot
reach it. The elab view is registered under the def view's import set at the copy
site. **POST: t62a's 12 listing scopes are IDENTICAL to golden's, byte for byte.**

`t61a` (pass 44's arm) re-measured on the final build: unchanged, including its
disclosed def-listing `q_chain` residue (golden 14 / ours 15) — not a regression
here, still open.

## 3. Ranked item (2) is DEAD: the package fixed unpacked array has ZERO corpus reach

Pass 44 localised `emitPkgArrayVar`'s `switch` returning false on
`FixedSizeUnpackedArrayType` and ranked it second, reach unmeasured.
`pkgarr.py` measures it — and **the shape does not occur at package scope
anywhere in either corpus.**

**This census caught its own false-positive mode, which is the reportable part.**
Version 1 said *"4 FIXED package-scope unpacked array variables in 3 files"* and
**all four were STRUCT MEMBERS inside a `typedef struct { … }`** —
`logic [31:0] pair[2];` in `HierPathUnpacked` / `HierPathUnpackedInPacked`,
`bit [31:0] keys[8];` and `exp_digest[8]` in Opentitan's `test_vectors_pkg.sv`.
The `typedef` line is (correctly) not pushed as a scope, so its BODY looked like
package scope. A struct member is a completely different emitter path, so those
hits could not have measured the shape at all. With the aggregate-body brace
tracking added: **0 in 0 files.**

And the census is validated by a **POSITIVE CONTROL** (`pkgarrctl/ctl.sv`),
because a census that reports zero is indistinguishable from a census that
cannot see anything: it finds all 3 FIXED spellings plus the 1 AMBIG one, and
correctly excludes `[$]`, `[]`, `[string]`, `[my_key_t]`, both struct members,
the typedef array and the parameter array.

Had it been non-zero, the tests would still have sunk it: `HierPathUnpacked` is
already `CMP_EQUAL` both modes, `HierPathUnpackedInPacked` is `SLANG_REJECT`, and
no test in the harness compiles Opentitan's `test_vectors_pkg.sv`.

## 4. Measurements — PRE re-measured on a fresh HEAD build, NOT inherited

PRE reproduces pass 44's committed panel exactly, which is the
baseline-validity check:

| metric (UVM-4) | pass 44 committed | HEAD re-measured | this pass |
|---|---|---|---|
| **`LSTOTAL`** | **811 (2/0/408/401), scope 11** | **811 (2/0/408/401), scope 11** | **3 (2/0/0/1), scope 3** |
| `CPTOTAL` | 580 (145/67/299/69) | 580 (145/67/299/69) | **580** unchanged |
| `LISTDIRECT` | 80 (22/18/22/18) vs golden 56 | 80 (22/18/22/18) | **80** unchanged |
| `r10uvm42tw` | 3863/3581/8148/3595 | 3863/3581/8148/3595 | unchanged |
| `r10uvm41ts` | 3827/3555/7974/3569 | 3827/3555/7974/3569 | unchanged |
| `r10uvm28a` | 3663/3276/7941/3276 | 3663/3276/7941/3276 | unchanged |
| `BINDWRONG` | 757 (43/87/521/106) | 757 (43/87/521/106) | **757**, no sub-class moved |
| `BINDTOTAL` | 1681 = 938 extra / 743 miss | 1681 = 938 / 743 | unchanged — the EXTRA half did not grow, the MISS half did not grow |
| `PAIRTOTAL` | 0 | 0 | 0 |
| `IOTOTAL2` / `IOTOTAL` | 3 / 2 | 3 / 2 | 3 / 2 |
| `INITTOTAL` / `CTORTOTAL` / `BODYOTHER` | 52 / 0 / 435 | 52 / 0 / 435 | 52 / 0 / 435 |
| `VARTOTAL` / `r10uvm23m` | 0 / 36 | 0 / 36 | 0 / 36 |
| `TSINSTTOTAL` / `CPCLASS` | 1074 / 25 | 1074 / 25 | 1074 / 25 |
| the 4 CSV rows | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` |

The 4 rows are still `CMP_NOTEQUAL`: uhdm-cmp's first unequal pair on all four is
a `decompile:` difference, so the listing vectors are not the row's current
blocker — **but they are the first thing cmp reads, so this deficit had to close
before that verdict could ever change.**

Post-law module tables, against golden, in order:
`SimpleUVM` 123/123 def and top, 0 diff; `SeqDriver` 125/125 def and top, 0 diff;
`comm` both ways EMPTY.

### The gates, on this worktree's own binary

`SLANG_UHDM` pinned to this worktree's `build/slang-uhdm` for every run
(`verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one).

* goldens **23 PASS / 0 FAIL**, with a **NEGATIVE CONTROL on the gate script
  itself**: `SLANG_UHDM=/bin/false` gives **0 PASS / 23 FAIL**.
* u2r `testflags`: **0 diff lines** over 732 vs `results/gate_uhdm2rtlil.csv`
  (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`).
* Surelog both modes: **0 diff lines** over 1589 vs `results/golden_surelog.csv`,
  whole row INCLUDING `DUMP` — so `SLANG_REJECT` membership is unchanged by
  construction, every canary row is identical, and no pinned giant flaked.
* the HEAD half of the byte verifier is likewise **0 diff lines** against the
  committed baseline — a baseline-validity check on the box.
* **byte verifier: 953 databases paired, 949 byte-identical, EXACTLY 4 DIFFER,
  and all four are the intended targets** — `SeqDriver` and `SimpleUVM` in BOTH
  modes, with **nothing to excuse**: `Scoreboard` did not flake on this run.
  Both runs wrote to the SAME workdir path. **This is the whole reach
  statement**: the law changes exactly the two target tests and nothing else in
  953 databases, which is why every derived metric in the panel is identical, and
  it is also the guard on the merge's one lossy property (below).

**GATE HISTORY, stated in full because one run of it is VOID.** The law was
gated three times, because it changed twice after the first gate:

1. module arm alone — goldens 23/23, u2r 0 diff, Surelog both 0 diff, byte
   verifier 948/953 (the 4 targets + a `Scoreboard` flake).
2. + collision cell + interface arm — goldens 23/23, u2r 0 diff. **Its byte
   verifier run is VOID AND NOT COUNTED: I rebuilt the binary WHILE that sweep
   was running** (adding the one-record-per-view guard), so its POST half was
   produced by a mixture of two binaries. It reported 948/953 with the same rows,
   which is presumably why the taint was invisible — *a tainted measurement that
   AGREES with the truth is still not a measurement.* **NEVER REBUILD DURING A
   SWEEP.**
3. the FINAL binary (module + collision + interface + the guard), re-gated IN
   FULL with no build touching the tree: **the numbers in this section are that
   run's, and only that run's.** goldens 23/23 + negative control 0/23, u2r 0
   diff over 732, Surelog both 0 diff over 1589, byte verifier 949/953 with
   exactly the 4 target rows.

### The `Scoreboard` exclusion — needed for the earlier runs, NOT for the final one

The final byte verifier has no `Scoreboard` row at all, so nothing here rests on
an exclusion. It DID appear in the earlier two runs, and the control was run
anyway, because next pass will hit it again:
`detcheck4.sh Scoreboard 4 4 /tmp/r10uvm45_head_bin` — **ONE binary, the HEAD
one** — produced

    run1 e6b9b552e9434398   run2 e6b9b552e9434398
    run3 ebe12c0a64f79822   run4 ebe12c0a64f79822

**two distinct hashes from the HEAD binary alone**, and the POST binary produced
`ebe12c0a` x4, i.e. one of HEAD's own two. Independently, in the UVM-4 sweeps the
HEAD and POST `Scoreboard` databases are **byte-identical** (`ebe12c0a…`), and
its `LSTOTAL` scope diff is 0 before and after with an EMPTY listing diff between
the two builds. Pre-existing intermittent flake (MEMORY.md's macro-buffer
`SourceLocation` mechanism).

**`detcheck4.sh`'s HEADER WAS CORRECTED, not inherited.** It asserted that the
flake is JOBS-DEPENDENT. The pass-44 verifier refuted that — `--jobs` is only
verify_golden.py's TEST-LEVEL pool width and the driver runs a single
`--filter`ed test, so `--jobs 1` and `--jobs 4` are the identical workload and
that experiment cannot separate them. The header now says so; the substantive
rule (the flake is INTERMITTENT, so one identical sample is not proof) stands.

### Two apparatus defects this pass hit, both caught, both fixed

* **`modcls.sh`'s first run printed `0 diff lines` on all five comparisons** —
  because `seq.sh` had not been made executable (the `chmod` was in a compound
  command the sandbox refused). *A DRIVER THAT CANNOT FIND ITS HELPER REPORTS
  PERFECTION*, one pass after `cp.sh` printed `golden=0 ours=0 diff=0` for the
  same class of reason. `modcls.sh` now refuses to print a number unless the
  helper is executable AND all three golden sequences are non-empty; `cpall.sh`
  refuses to sum a census whose golden side is empty.
* **THE MERGE IS NOT IDEMPOTENT, and a second record per view would have been
  INVISIBLE to every census here.** Running it twice on one scope re-adds each
  class-key object at its CLASS key while the object is already listed under its
  OWN name; identity dedup then keeps whichever key sorts first, so entries MOVE
  while the COUNT stays the same — and a count is what a size mismatch reports.
  Guarded at the source: one record per view, checked by pointer, in both the
  emission recording and the elab-interface registration.
* **`seq.sh` matched the WRONG SCOPE.** A design has one `module_inst ''/def`
  line per module (the def view's `VpiName` is empty) — `SimpleUVM` has three —
  and `head -1` picked an `n=0` one, so the driver computed its diffs from a
  ONE-ENTRY sequence and printed numbers that looked like measurements
  (`gmd n=1`, `124 diff lines`). It now takes the LARGEST match and echoes the
  chosen line's `n=` to stderr so the choice is auditable.
* `clone44.sh` re-namespaces pass 44's drivers by a sed anchored to the
  `/tmp/r10uvm44_` PREFIX ONLY, never the probe binary names — pass 44's
  `clone43.sh` renamed the binaries with a blanket sed. `clone44.sh --check`
  verifies every driver's `V=` exists after `probebuild.sh` runs.

## 5. What is left, MEASURED — pass-46 ranking

**(1) `LSTOTAL`'s last 3, both localised, neither a listing-content bug:**
  * `SimpleUVM` 1 — a **MISSING OBJECT**, i.e. the `r=1 failLhs=<container>`
    vector-SIZE class, the highest-value cmp class there is. Golden holds THREE
    `interface_inst` objects (an unnamed def view plus `add_sub_if0` **TWICE**)
    where we hold TWO (golden 5152 listing scopes, ours 5151). Source:
    `bind ADD_SUB add_sub_if add_sub_if0(...)`.

    **AND THE DISTINGUISHER IS ALREADY IN HAND, as a 2x2 with a CANARY on the
    other side.** `tests/InterfaceBinding/dut.sv` is the SAME source shape —
    the same `ADD_SUB`, the same `add_sub_if`, the same `bind` line, the same
    instance name — and there `golden interface_inst = 2, ours = 2, MATCH`
    (`ifcount.sh /tmp/…bvw3 InterfaceBinding`), with the test `CMP_EQUAL` and
    `DUMP=match` in both modes. **The one thing SimpleUVM adds is that `ADD_SUB`
    is INSTANTIATED** (`ADD_SUB dut(.clk(clk));` inside `top`); InterfaceBinding
    has no instantiating module at all. So the law to write is: a `bind`
    instance appears in the target module's DEF view AND once per ELABORATED
    copy of that module — and `InterfaceBinding` is the regression control that
    says the def-view-only count must not change when the module is never
    instantiated.

    **Reach, measured:** the other dedicated bind tests cannot help or hurt —
    `BindStmt`, `BindStmt2`, `BindingPort` are all `SLANG_REJECT`.
  * `BuildUVMPkg` 2 — a **NAME** law, not a population one, and the populations
    say so exactly: **total `task_func` objects 5275 in golden and 5275 in ours;
    golden has ONE with an EMPTY `VpiName` and ZERO named `ceil`, ours has ZERO
    empty and ONE named `ceil`** — a 1:1 complement, i.e. one object renamed.
    The source is `uvm_pkg.sv:75228`,
    `local function automatic int unsigned ceil(int unsigned a, int unsigned b);`
    — a `local` class method with an `int unsigned` return, so the candidate
    distinguishers are `local` and the two-token return type. `VpiName` is a
    COMPARED field. (Strictly this is a population complement, not object
    identity; an identity probe was not run, and the honest claim is "one object
    renamed OR one extra plus one missing".)

**(2) THE PROGRAM ARM of § 45 — genuinely unmeasured, and the measurement is
blocked on the PROBE, not on a golden.** `t62a` carries a `p63` with the same
import; `r10uvm44ls` has no `program` case, so it produced no row. Add the case
(a `program` is an `instance` with `Typespecs()` like the rest) and read t62a's
existing golden — no new Surelog run needed. Same for the INTERFACE's FILE-SCOPE
import, deliberately not implemented (the interface typedef listing walks BODY
imports only, so publishing keys for a file-scope-imported package would list
keys whose typedefs are absent).

**(3) carried, unchanged, with their pass-44 measurements:** the `types_t`
ELEMENT position (three extra objects of ours, the whole of `LISTDIRECT`'s
`int_typespec` row — still the ranked item whose fix REMOVES objects); the
238-row unspanned empty `array_typespec` family (98/23/94/23); the four t60a
`LISTED` rows whose listing-object SPAN differs (36:11-74:23 vs 36:11-36:20,
dump-only); t61a's package DEF-listing atom chain (golden 14 / ours 15, an extra
of ours, fix REMOVES an object); the module-implicit-net arm (owns `BINDTOTAL`'s
disclosed +4, a wash because `r10uvm28m` keys on a SET of actuals); `BARE -> SELF`
438 rows, HOMOGENEOUS PER ROUTINE (354 owners all-SELF, 1082 all-BARE, 26 mixed —
read the SOURCE of a few owners on each side); `BINDWRONG`'s 342
owner-attribution and 82 parameter-vs-folded-constant rows; the `IOTOTAL2`=3
POPULATION row (same object as `IOTOTAL`-2 and `r10uvm23m` tf=2, so one law may
close three metrics); `TSINSTTOTAL` 1074 (golden HAS 26 class-instanced rows, so
do not assume never-the-class); `CPCLASS` 25; the MODULE arm of
§ `classKeyTsScopeOwner35` — **note it is newly READABLE**, since its stated
blocker was "our module listings carry no class keys to read the order off" and
now they do (still 0 rows on the UVM-4, so no gain expected); the socket sharing
residue; the clone-SHARING residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=34;
t36b; t33d.

**(4) STILL NAMED AS UNMEASURED, not settled:** the ELEMENT half of pass 43's
widened kind gate (golden's arms have ZERO container-ELEMENT rows, so that
per-kind table is an INDEX-position measurement and the element half is
inference), and `real`/`shortreal`/`union`/class-handle in either CONTAINER
position. `t61a` and `t62a` witness kinds as LISTING objects, which is a
different question from what a container position BINDS.

## 6. Reproduce

    tools/probe/r10uvm45repro/clone44.sh                      # drivers (prefix-anchored sed)
    tools/probe/r10uvm45repro/probebuild.sh r10uvm44ls r10uvm43cp r10uvm42tw \
        r10uvm41ts r10uvm28a r10uvm40av r10uvm28g r10uvm30io r10uvm29io \
        r10uvm27s r10uvm23b r10uvm26v r10uvm29v
    tools/probe/r10uvm45repro/clone44.sh --check              # every driver finds its probe
    tools/probe/r10uvm45repro/uvm4.sh    <out.csv> <workdir> [binary]
    tools/probe/r10uvm45repro/ls.sh      <workdir> <tag>      # LSTOTAL
    tools/probe/r10uvm45repro/modcls.sh  <test> <tag>         # THIS PASS'S measurement
    tools/probe/r10uvm45repro/seq.sh     <ls-dump> <scope-prefix>
    tools/probe/r10uvm45repro/armls.sh   t62a|t61a|t60a <outdir> [binary]
        # resolves the arm across the sibling *repro dirs — an arm keeps its
        # BIRTH pass's directory (t62a here, t61a in r10uvm44repro, t60a/t60b in
        # r10uvm43repro) rather than being copied forward, so there is never a
        # second copy of the source a golden was cut from.
    tools/probe/r10uvm45repro/pkgarr.py  <root> [root ...]    # and on pkgarrctl/
    tools/probe/r10uvm45repro/panel.sh   <workdir>
    tools/probe/r10uvm45repro/res.sh     <workdir> <tag>
    tools/probe/r10uvm45repro/cpall.sh   <workdir> <tag>      # CPTOTAL + CPCLASS
    tools/probe/r10uvm45repro/listdirect.sh <tag>
    tools/probe/r10uvm45repro/tsinst.sh  <workdir>
    tools/probe/r10uvm45repro/ifcount.sh <workdir> <test> [mode]   # § 5(1)
    tools/probe/r10uvm45repro/gate.sh    goldens|u2r|sl|slbin ...
    tools/probe/r10uvm45repro/byteverify.sh <wd> <head-bin> <csv-head> <csv-post>
    tools/probe/r10uvm45repro/detcheck4.sh <Test> <N> <jobs> [binary]
    tools/probe/r10uvm45repro/csvdiff.sh <baseline.csv> <new.csv>
