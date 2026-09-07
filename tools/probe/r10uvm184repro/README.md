# r10uvm184 — § `cloneBuiltinMethodArgBindsReceiver184` — **A WILDCARD-IMPORT CLONE BINDS A BUILT-IN STRING METHOD'S ARGUMENT TO THE RECEIVER** — the SeqDriver ×2 / MiniAmiq ×2 29-line head CLEARED

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
| BASE | `b71d5feb` |
| pristine binary | md5 `bc09e77cf8fd251285c06f6f0b54a5bc`, built from this pass's OWN worktree at a clean `b71d5feb` and frozen `chmod 555` before any sweep |
| patched binary | md5 `554e02b892d0377e734bc253c20181d6`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` (one recording block in the built-in method arm), `src/UhdmExporter.cpp` (one design-final drain), `include/UhdmExporter.h` (the law, one pool, one recorder) |
| probe surface | `tools/probe/r10uvm184repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default/testflags AND MiniAmiq default/testflags, 29 cmp lines, ONE `^LHS:` each, the SAME object in all four row-modes → cleared.** Successor: `int_var (uvm_pkg::uvm_packer::get_bytes::sz)`, 31 lines, one head, the two modes byte-identical on each row. |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **surelog 4 / 956**, all four PREDICTED BY NAME from the PRISTINE databases and their goldens alone (`predict184.sh`, §5). **0 / 1358** uhdm2rtlil. |
| the corpus population | the DIRECT name arguments of a built-in STRING method call inside a wildcard-import clone body: **11 keys x 2 clone copies = 22 cells per clone row-mode**, in five UVM subroutines. |
| the census (nine UVM row-modes) | **TOWARD 11 keys per clone row-mode, AWAY 0, MOVED-WRONG 0, ONLY-OURS-MOVED 0**; the five non-clone row-modes score TOWARD 0 / AWAY 0 and are untouched. Calibrated golden-vs-golden FIRST: every column 0. |
| the grid (2 arms × both views) | arm A **TOWARD 12 / AWAY 0 / MOVED-WRONG 0** in both views; arm B (the receiver-KIND axis, which is where the fence comes from) **TOWARD 1 / AWAY 0 / MOVED-WRONG 0** in both views. |
| the WIDE boundary (5019 arms × both views) | `LISTED=5019 FENCED_SKIPPED=0 PROCESSED=5019 PROCESSED-ASSERT-OK`, **MOVED 6 arm-views**: this pass's two arms (4) and `r10uvm171repro/g171_a_pos.sv` (2), which was rebuilt against its OWN real Surelog golden and scores **TOWARD 2 / AWAY 0 / MOVED-WRONG 0** in both views while staying `uhdm-cmp` rc=0 on BOTH binaries. Every § 139 / uvm180-183 / uvm89 / buvm3-15 / sd8-12 arm is byte-identical. |
| what the fence caught | the first cut had NO string fence and moved `visited.exists(succ)` (uvm_phase.svh:1907/1955) from one wrong answer to another — a **MOVED-WRONG** the array arm of the grid names outright. See §3. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `b71d5feb` worktree, ran
its 23/23 goldens, and reproduced the committed surelog baseline row for row
(`ct8rows` 0 differing rows over 1588, status AND dump column) before a line of
code was written. `rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         29      1
SeqDriver      testflags       29      1
SimpleUVM      ×2          664681      1
Scoreboard     default         95      1
MiniAmiq       default         29      1
MiniAmiq       testflags       29      1
BuildUVMPkg    ×2              52      1
Earlgrey_0_1   default/tf   31 / 364    1
Rggen          default    CMP_EQUAL
```

The head, identical on all four row-modes (`head_pris_*.cmp`):

```
LHS (golden)
string_var: (uvm_pkg::uvm_table_printer::emit::dash)  line:1040:17-1040:21
|vpiParent:
\_begin: (uvm_pkg::uvm_table_printer::emit)           line:1039:3-1039:22
|vpiTypespec: -> ref_typespec -> string_typespec      line:1040:10-1040:16
|vpiName:dash
RHS: <null>
```

### THE BRIEF'S FRAMING IS REFUTED — the listing is not the question

The brief read this as a LISTING miss: *"golden lists the static string
declaration as a variable of its enclosing begin block; our listing omits it."*
`ct184own.cpp` (the owner-finder, r10uvm164's mirror form generalised to run the
scan on whichever side of the head is non-null) says otherwise, on the pristine
databases:

```
golden begin()@1039:3-1039:22   vpiVariables (vector) size 6, [2] = string_var(dash)@1040:17
ours   begin()@1039:3-1039:22   vpiVariables (vector) size 6, [2] = string_var(dash)@1040:17
golden function(emit)@1036:1    vpiVariables (vector) size 6, [2] = string_var(dash)@1040:17
ours   function(emit)@1036:1    vpiVariables (vector) size 6, [2] = string_var(dash)@1040:17
```

**Both sides list `dash` at the same index of the same six-entry vector, on the
`begin` AND on the function, with the same span, in every one of the four
listings** (the in-body class listing, the package out-of-body listing and the
clone's two copies). The `s / user_format / dash / space / dashes / linefeed`
declarations of `uvm_table_printer::emit` (uvm_printer.svh:1038-1044) are
listed identically on both sides, `vpiAutomatic` included (that is
§ `tfItemLocalAutomaticIsNotWrittenStatic139`'s, landed and unmoved). The judge
never asked about the listing at all.

### DECODING THE JUDGE — which of fifteen referrers it stopped on

`RHS: <null>` with a present LHS is `BaseClass.h`'s SINGULAR `SafeCompare`
naming a VALUE (RESUME §9). Fifteen golden objects hold a singular `vpiActual`
onto this `string_var`. Two instruments were needed to say WHICH:

* `ct184field.cpp` rules out the other overload: the head pair's every
  `GetByVpiType` edge is present on both sides and every vector has the same
  size, so this is NOT the vector overload's `rhs == nullptr` branch (which
  would name the OWNER as LHS).
* `ct184which.cpp` (null a candidate edge, re-compare) is **not** a sound
  discriminator and is kept only as the record of that: nulling an edge the walk
  reaches EARLIER manufactures a new failure there and moves the head too.
* `ct184skip.cpp` is the instrument that answers it. Every generated
  `ref_obj::Compare` opens with
  `if (!context->m_visited.insert(this).second) return r;`
  (`UHDM/build/generated/src/ref_obj.cpp:129`), so PRE-SEEDING a golden object
  into `CompareContext::m_visited` makes the judge SKIP that object and keep
  walking, **with no edit to either database**. Skipping a referrer reached
  before the head leaves the head UNCHANGED; skipping the head's own referrer
  MOVES it. Fourteen of the fifteen read UNCHANGED. The fifteenth:

```
skip ref_obj(m_max_value)@1080:39-1080:50  -> head MOVED to int_var(sz)@485:7 / <null>
     chain <method_func_call:substr:1080 <hier_path:dash.substr:1080 <operation:1080
           <assignment:1080 <begin:1065 <if_else:1065 <begin:1062 <if_stmt:1062
           <begin:1039 <function:uvm_table_printer::emit:1036 <package:adpcm_pkg:10
```

**The head is the `vpiActual` of the SECOND ARGUMENT of
`dash.substr(1,m_max_value)`** (uvm-1.2 `uvm_printer.svh:1080`) in the
**adpcm_pkg wildcard-import CLONE listing** — which golden binds to `dash`, the
call's RECEIVER, and which we leave BARE.

---

## 2. THE DECODED MODEL

> **§ `cloneBuiltinMethodArgBindsReceiver184`.** In a WILDCARD-IMPORT **clone**
> of a package subroutine, every DIRECT name argument of a **built-in STRING
> method call** on a receiver carries the **RECEIVER's** `vpiActual` as its own,
> whatever the argument's own declaration is — a subroutine LOCAL, a FORMAL, a
> CLASS PROPERTY and an ENUM CONSTANT alike, at argument position 0 and 1 alike.
> At HOME (the declaring package's own views and the class listing) the argument
> keeps its ordinary binding. An argument that sits inside an OPERATION is not a
> direct argument and is untouched. An ARRAY receiver has a different rule
> entirely and is fenced out.

**The producer.** The clone is a second elaboration of the same body in the
importing package's scope, and UHDM's own elaborator does the binding:
`ElaboratorListener::enterMethod_func_call`
(`UHDM/templates/ElaboratorListener.cpp:1475-1489`) pushes an instance-stack
entry for the CALL itself, and `leaveRef_obj` (`:1498-1510`) then runs
`bindAny` (`:899`) over that stack for every reference under it — a lookup whose
FIRST map hit wins and is returned whatever it resolves to. The home listing is
written before that pass runs and keeps the compiler's own answer, which is why
the same source line has two different answers in one database.

**The golden matrix** (`g184_a_recv.sv`, one real Surelog golden, both views,
read with `ct184mfc.cpp` — one row per reference whose immediate parent is a
`method_func_call`, carrying the receiver's actual beside the argument's):

| argument is | position | receiver is | home listing | CLONE listing |
|---|---|---|---|---|
| subroutine LOCAL | arg1 | local string | its own declaration | **the receiver** |
| subroutine LOCAL | arg0 | local string | its own declaration | **the receiver** |
| FORMAL | arg1 | local string | its own declaration | **the receiver** |
| CLASS PROPERTY | arg1 | local static string | bare | **the receiver** |
| ENUM CONSTANT | arg1 | local static string | bare | **the receiver** |
| subroutine LOCAL | arg1 | a FORMAL string | its own declaration | **the receiver** |
| subroutine LOCAL | arg1/arg0 | the function's own RETURN NAME | its own declaration | **the receiver** |
| two LOCALS at once | arg0+arg1 | local string | their own declarations | **both the receiver** |
| a LOCAL inside an OPERATION | — | local string | *(not an argument — no row)* | *(no row)* |
| subroutine LOCAL | arg1 | a CLASS PROPERTY string (receiver BARE) | bare | its own declaration |

The last line is the law's own boundary from the other side: when the RECEIVER
is itself unbound there is nothing to copy and golden leaves the argument alone
— which is exactly what the drain does (`if (!act) continue;`).

---

## 3. THE STRING FENCE — measured, and it convicted the first cut

`g184_b_kinds.sv` varies the RECEIVER instead of the argument, in the same
clone. One golden, both views:

| receiver | call | golden's answer for the NAME argument |
|---|---|---|
| `string cable` | `cable.substr(1,kink)` | **the receiver** (`string_var(cable)`) |
| `string cable` | `cable.getc(kink)` | **the receiver** (`string_var(cable)`) |
| `int tackle[int]` | `tackle.exists(kink)` | an `int_var` NAMED `kink` spanned at **`tackle`'s own declaration** — not the receiver |
| `int rope[$]` | `rope.find_index(kink)` | an `int_var` NAMED `kink` spanned at **`rope`'s declaration** — not the receiver |

The corpus holds that counter-example: `visited.exists(succ)` in
`uvm_phase::sync` and `::unsync` (uvm-1.2 `uvm_phase.svh:1907` and `:1955`, over
`int visited[uvm_phase];` at `:1896` / `:1946`) — golden binds `succ` to
`int_var (succ) @1896:9`, an object at the ASSOCIATIVE ARRAY's declaration span
named after the ARGUMENT, while the receiver's actual is
`array_var (visited) @1896:9`.

**The first cut had no fence and moved those four cells** (two subroutines × two
clone copies) from `ref_var(succ)@1906:34` — wrong, but wearing the right NAME —
to `array_var(visited)` — wrong AND wearing the wrong name, which the judge
reads. That is a MOVED-WRONG, and the order-blind mover attribution is what
showed it (`\_ref_var: (…::uvm_phase::sync::succ)` out,
`\_array_var: (…::uvm_phase::sync::visited)` in). The law is therefore stated
over a built-in **STRING** method call: the gate is the receiver expression's
own slang type (`stripImplicitConv(*recv).type->isString()`). With the fence the
corpus cells are byte-identical to pristine and the grid's array arm scores
AWAY 0 / MOVED-WRONG 0.

The other-object family (an `int_var` named after the argument at the array's
declaration span) is **R2** and is deliberately not modelled.

---

## 4. WHAT SHIPPED

Three files, one law:

* `include/UhdmExporter.h` — the law in full, the pool
  `cloneMfcArgRecv184` (argument reference, receiver reference) and the recorder
  `noteCloneMfcArgRecv184`, which is inert unless `funcRetSelRefs171` is
  non-null. That pointer is § `retNameSelBindsHomeReturnInCloneOnly171`'s own
  clone gate — armed for a wildcard-import clone body and for nothing else — so
  no home-package body, no class body and no module body can push a single pair.
* `src/ExprEmit.cpp` — ONE site, in the built-in method arm, right after
  `Tf_call_args` is set and before the call is pushed into `Path_elems` (so
  `elems->back()` IS the written receiver). Gated on the clone pointer AND on
  the receiver expression's type being a string.
* `src/UhdmExporter.cpp` — `drainCloneMfcArgRecv184()`, called DEAD LAST in the
  design-final sequence, after every pool that can still bind a receiver
  element. At emission time `recv->Actual_group()` is null for every corpus
  cell, so the copy has to be deferred; a receiver that is still bare at the end
  hands the argument nothing.

---

## 5. THE A-PRIORI PREDICTION (over all 956 surelog + 1358 u2r databases)

`predict184.sh` replays a COMPLETED PRISTINE sweep workdir: for every row it
reads the row's OWN golden out of the row's `cmds.txt` (never guessed), runs
`ct184mfc` on the golden and on the PRISTINE database, and asks the law's
question of that pair alone — *does any argument key exist that GOLDEN binds to
the receiver and the pristine database does not?* A row with no such key cannot
move. The predicate is a SUPERSET of the law's own gate (a database cannot say
whether a listing is a wildcard-import clone), so it can over-name and never
under-name.

```
LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4
PREDICT default/MiniAmiq-544c7f61  cells=12
PREDICT default/SeqDriver-32af76aa cells=12
PREDICT testflags/MiniAmiq-544c7f61  cells=12
PREDICT testflags/SeqDriver-32af76aa cells=12
```

Every row that produced a pristine database was processed and every one had its
golden (`NOGOLDEN=0`), so the prediction covers the whole comparable population.
The twelve cells per row are the ten this law owns plus the two `exists` cells
the string fence deliberately leaves alone (§3) — the predicate does not know
about the fence, which is the point of a superset predicate.

`byteverify.sh SELFCHECK=1` on the accepted patched sweep then reported
**MOVERS 4 / 956 — precisely those four and no others** (SELFCHECK 955/956), and
**0 / 1358** on uhdm2rtlil.

An earlier patched sweep of the SAME binary reported 5, the fifth being
`Scoreboard/default`, whose ORDER-BLIND dump diff was ZERO content lines: the
svunit_pkg `vpiTaskFunc` order COIN (RESUME §9), which sat out on the accepted
run. It is recorded here because a coin that lands the other way is a
measurement, not a regression, and the order-blind diff is the only sound read
of it.

---

## 6. MOVER ATTRIBUTION, ORDER-BLIND AND NAMED

`attrib184.sh` dumps both databases with `uhdm-dump`, normalises the workdir out
and strips `id:` numbers, then diffs PLAIN and SORTED. The sorted diff is the
only sound attribution for a coin row.

| database | mode | plain | order-blind | content lines |
|---|---|---|---|---|
| SeqDriver | default / testflags | 46 / 46 | 46 / 46 | **44** |
| MiniAmiq | default / testflags | 46 / 46 | 46 / 46 | **44** |
| Scoreboard | default (the coin run) | 94 | **2 (the dump header alone)** | **0** |

Every content line of the four real movers is a `vpiActual` target and nothing
else, by name:

```
out                                                    in
int_var  (…uvm_default_factory::print::max1/2/3)   ->  string_var (…::print::dash)
int_var  (…::m_debug_display::max1/2/3)            ->  string_var (…::m_debug_display::dash)
int_var  (uvm_pkg::uvm_instance_scope::pos)        ->  string_var (uvm_pkg::uvm_instance_scope)
int_var  (uvm_pkg::uvm_split_string::s)            ->  io_decl (str)
(nothing — the cell was BARE)                      ->  string_var (…::uvm_table_printer::emit::dash)   <- THE HEAD
```

**Twenty-two cells per clone row-mode** (eleven keys x the clone's two copies):
twenty replaced an existing binding, two filled a BARE one (the head), for
**44 content lines** per mover - 20 `<`, 24 `>` (the head's two cells each add a
`|vpiActual:` marker line as well). Nothing else in any database changed.

---

## 7. RESIDUES AND R0

* **R0 — the next head.** SeqDriver ×2 and MiniAmiq ×2, **31 cmp lines, ONE
  `^LHS:`**, the two modes byte-identical on each row:
  `int_var (uvm_pkg::uvm_packer::get_bytes::sz) @485:7-485:9 < begin
  (uvm_pkg::uvm_packer::get_bytes) @486:3` with `RHS: <null>`. It is the SAME
  FAMILY one method further on: the argument of a `new` method call
  (`byte_stream = new[sz]`-shaped) in the clone listing, which golden binds to
  `int_var(sz)` and we leave without a counterpart. `head_pat_*.cmp`.  (SimpleUVM's own cmp log is the
  664681-line depth artifact and is deliberately not carried here.)
* **R1 — the EXPLICIT-import copy.** `import P::f;` produces a copy that golden
  treats exactly like the wildcard clone (arm A, `package:Fillet184`, six keys ×
  2 copies, both views), and this law does not fire there because its gate is
  § 171's wildcard-only pointer. **Corpus incidence: zero** — the predictor
  names no explicit-import cell in 956 + 1358 databases.
* **R2 — the ARRAY receiver's own object.** An associative or queue receiver's
  argument binds, in golden, to an `int_var` NAMED AFTER THE ARGUMENT and spanned
  at the ARRAY's declaration. Four corpus cells
  (`uvm_phase::sync`/`unsync`'s `visited.exists(succ)`, two clone copies each)
  and two arm-B cells. Deliberately untouched — see §3.
* **R3 — the class listing's own class-property argument.** `braid.substr(1,
  m_girth)` in the CLASS listing reads golden `OTHER` (the class property) and
  ours BARE, in both binaries (arm A, `package:Quarry184+cls`). A class-property
  binding question, not this law's; identical pristine and patched.
* **R4 — the `arg-1` PREFIX reference** (`cb.post_predict(...)`'s `cb`) is not an
  argument and is excluded from every score here; `uvm_reg_field::do_predict` /
  `do_read` / `do_write` carry six such cells where golden binds and we do not.
  Untouched by this pass.

---

## 8. REPRODUCING

```sh
g++ -O2 -std=c++17 ct184own.cpp   -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184own
g++ -O2 -std=c++17 ct184skip.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184skip
g++ -O2 -std=c++17 ct184field.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184field
g++ -O2 -std=c++17 ct184which.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184which
g++ -O2 -std=c++17 ct184cen.cpp   -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184cen
g++ -O2 -std=c++17 ct184mfc.cpp   -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184mfc
g++ -O2 -std=c++17 ct184dump.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184dump

./ct184own  <golden.uhdm> <ours.uhdm> [scope-substr] [var-substr]   # the head's owner, both directions
./ct184skip <golden.uhdm> <ours.uhdm>                               # WHICH referrer the judge stopped on
./ct184mfc  <db.uhdm> [subr-substr]                                 # the argument-binding census
CT184MFC=./ct184mfc ./grid184.sh g184_a_recv.sv  <pris.bin> <pat.bin> <workdir>
CT184MFC=./ct184mfc ./grid184.sh g184_b_kinds.sv <pris.bin> <pat.bin> <workdir>
python3 score184.py <g.mfc> <pris.mfc> <pat.mfc>
CT184MFC=./ct184mfc ./predict184.sh <PRISTINE workdir> <out.txt>
CT184MFC=./ct184mfc ./cenall184.sh  <pris wd> <pat wd> <outdir> SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg
./attrib184.sh <pris wd> <pat wd> <outdir> 'SeqDriver|MiniAmiq|Scoreboard'
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=/tmp/r10uvm184_bound ./bound184.sh
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ../r10oth4repro/byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
bash canaudit.sh canaries.sh ctcan2.sh
```
