# r10buvm16 — § `newArrayArgNoBind16` — **the BuildUVMPkg head cleared, and the dynamic-array `new[...]` argument family closed on both corpora**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `89bfd8f` |
| worktree | `/tmp/wt_r10buvm16` |
| pristine binary | md5 `0b03a633a9020a3cb7f26346ff6d22d4` |
| patched binary | md5 `f37116e36f261e4dfbe1b728938e84da` |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one RAII window, one symbol predicate, one gate disjunct |
| probe surface | `tools/probe/r10buvm16repro/` only |
| deliverable | `/tmp/r10buvm16.patch`, applies clean on a FRESH `89bfd8f` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS`.  What it does is clear buvm15's residue R0 and close the dynamic-array
`new[...]` argument family across both corpora.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines, default / testflags | **31 / 31** | **29 / 29** (a DIFFERENT head) |
| head object | `LHS <null>` / `int_var(…get_packed_bytes::sz)` | `byte_var(…get_packed_bytes::i)` / `RHS <null>` (**R0**) |
| `new`-argument census, surelog corpus, DISAGREE rows | **50** | **10** |
| the same, AGREE rows | 4399 | **4439** |

**THE CENSUS NUMBERS ABOVE ARE THE `--loconly` READING** and `cenjoin16.py` does
NOT default to it — reproduce them with
`cenjoin16.py <g> <o> --loconly` (verifier r10vbuvm16: the file-keyed default
reads `4299 / 20` and `4319 / 0` on the same censuses, because 30 of the
pristine disagreements sit in the 240 extra ARITY buckets the file key creates.
See § 4; the flag, not the default, is the sound join).
| byte movers | — | **9 / 956** surelog, **0 / 1358** u2r, all 9 predicted BY NAME first |

Both modes' cmp logs are byte-identical to each other on both binaries
(`d5d67489da8f` pristine, `16780a99e816` patched), and the other **ten** cmp
logs of the seven-row head set are **byte-identical between the two binaries**.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

Read out of `/tmp/r10buvm16_heads_pris/BuildUVMPkg.default.cmp` before any code
was written:

```
LHS: <null>
RHS:
decompile:
int_var: (uvm_pkg::uvm_packer::get_packed_bytes::sz), id:42239, line:22227:8, endln:22227:10
…
```

`BaseClass.h`'s SINGULAR `SafeCompare` has exactly one arm that prints this
shape:

```cpp
} else if ((lhs == nullptr) && (rhs != nullptr)) {
  context->m_failedRhs = rhs;      // the VALUE, not the owner
  return -1;
```

(the VECTOR overload's asymmetric arms set the OWNERS and are guarded by
`!rhs->empty()`, so they cannot produce a `<null>` LHS with a *variable* on the
right).  `ref_obj::Compare`, read in
`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:122`, has exactly ONE singular
`SafeCompare`: `Actual_group()`, compared after `VpiName` / `VpiDefName` /
`VpiGeneric`.  So the head is a `ref_obj` whose golden `vpiActual` is **absent**
and whose ours is that `int_var`.

The owner was then located **by measurement, not by the brief**: the census
(`r10buvm16cen`) prints, for every `new` call in a database, every argument
ref's `Actual_group`, and the two databases answer

```
G  key=uvm_pkg.sv|22232:13 nm=new par=NONE  a=0=ref_obj(sz)[sz@22232:17->BARE]        (×2)
P  key=uvm_pkg.sv|22232:13 nm=new par=NONE  a=0=ref_obj(sz)[sz@22232:17->int_var(sz)] (×2)
```

i.e. `uvm_pkg.sv:22232` `stream = new[sz];` inside the OUT-OF-BODY method
`function void uvm_packer::get_packed_bytes(ref byte unsigned stream[])`.

## 2. THE LAW, DECODED FROM THE PRODUCER

Surelog's `CompileHelper::compileBlockingAssignment`
(`CompileHelper.cpp:4483-4498` and `:4536-4552`) has TWO `new` arms, and they
differ in **one line**:

```cpp
// paDynamic_array_new            d = new[n] ;  d = new[n](src) ;
method_func_call* fcall = s.MakeMethod_func_call();
fC->populateCoreMembers(Delay_or_event_control, Delay_or_event_control, fcall);
fcall->VpiName("new");                       //  <-- NO VpiParent, ever
… compileTfCallArguments(component, fC, Delay_or_event_control,
                         compileDesign, Reduce::No, fcall, nullptr, false)

// the CLASS form                 h = new(args) ;
fcall->VpiName("new");
fcall->VpiParent(assign);                    //  <-- PARENTED
… compileTfCallArguments(… , fcall, …)
```

Both compile the argument list with the `fcall` as `pexpr`.
`CompileHelper::bindVariable` (`CompileStmt.cpp:3089`) resolves a name by
**walking that `pexpr`'s `VpiParent` chain**, matching `Variables()` then
`Io_decls()` on the first `uhdmfunction` / `uhdmtask` / `uhdmbegin` it reaches —
the same walk buvm13 and buvm15 decoded.  From the dynamic-array `fcall` that
chain is **empty**, so the walk finds nothing, the ref is handed to
`component->needLateBinding(ref)`, and `UhdmWriter::lateBinding`
(`UhdmWriter.cpp:3294`) walks `ref->VpiParent()` — which is that same unparented
`fcall` — and finds nothing either.  `assign->Rhs(rhs_rf)` is a plain setter and
never back-fills a parent.

**Every subroutine-scope name under a `new[...]` therefore stays BARE**, and the
`new(args)` / `super.new(args)` forms are untouched because they are parented.
This is the same producer fact `§ newArray11` already recorded as "UNPARENTED"
in the emitter's own comment — it had been used for the NAMES (`stripRefFullNames11`)
and never for the ACTUALS.

**WHAT STILL BINDS.**  A PACKAGE variable under the same `new[...]` **is** bound
in golden (a2 cells p05 / p32 / p42): it never reaches `bindVariable` at all,
because `compileExpression` resolves a component-scope name against the package
before the `pexpr` walk is tried.  So the gate is a **symbol-scope test**, not a
blanket silence.

## 3. THE GRID — THREE ARMS, AND THE COUNTER-WITNESS THAT NARROWED THE LAW

`grid16.sh` prints golden / pristine / patched per site.  Verdicts: `same`,
`CONVERTED` (P wrong, Q == G), `OVER-FIRE` (P right, Q wrong),
`MOVED-STILL-WRONG`, `residue` (G != P == Q).

### a2 `a2_pkgonly16.sv` — A PACKAGE AND NOTHING ELSE, exactly BuildUVMPkg's shape
`-- residue=1 same=8 CONVERTED=18`, **0 OVER-FIRE, 0 MOVED-STILL-WRONG.**

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| p01 / p02 | OOB method, size = **local** / **formal** | BARE | bound | **BARE** |
| p07 | size = `oloc16 + g16`, an **operation** | BARE ×2 | bound ×2 | **BARE ×2** |
| p08 | size = `sz16(oloc16)`, a **nested call's own argument** | BARE | bound | **BARE** |
| p09 / p10 | the **two-argument** copy form `new[n](src)` | BARE | src bound | **BARE** |
| p14 | a **NAMED-block** local | BARE | bound | **BARE** |
| p15 | a **for-loop iterator** | BARE | bound | **BARE** |
| p20/p21, p30/p31 | OOB **task**, OOB **static** method | BARE | bound | **BARE** |
| p40-p45 | **package** function and **package** task | BARE | bound | **BARE** |
| **p05 / p32 / p42** | **a PACKAGE VARIABLE** | **`int_var`** | `int_var` | **`int_var`** |
| p03 / p04 | a class PROPERTY, bare and via `this` | BARE | BARE | BARE |
| p11 | `pkgarr16.size()`, a hier_path base | BARE | BARE | BARE |
| p50 / p51 | the IN-BODY control (§ `classMethodNoBind` already silences it) | BARE | BARE | BARE |
| p06 / p47 | a constant size | `constant` | = | = |

### a3 `a3_homes16.sv` — **THE COUNTER-WITNESS, and it narrowed the law twice**
`-- residue=7 same=7 CONVERTED=3`, **0 OVER-FIRE, 0 MOVED-STILL-WRONG.**

CORRECTED BY THE VERIFIER (r10vbuvm16).  The line shipped in the first cut read
`residue=5 same=10 CONVERTED=2` and its `r10` row read `same`; re-run on the
SHIPPED arm with the SHIPPED binaries — three times, and once with this
directory's own `grid16.sh` verbatim — the arm measures `residue=7 same=7
CONVERTED=3`, because `r10` CONVERTS and the two module-homed BIT-SELECT INDEX
cells (35:16-family lines 46 and 54) are residues, not `same`.  The
load-bearing claim is unchanged and was re-measured: **0 OVER-FIRE**.

| cell | written | golden | verdict |
|---|---|---|---|
| **r24 / r25** | an OUT-OF-BODY method of a class declared **INSIDE A MODULE** | **`logic_net (work@top3_16.eoloc16)`** | the law must NOT fire — residue |
| **r40 / r41** | a **module** function's local / formal | **`logic_net`** | the law must NOT fire — residue |
| **r44** | a **module** `initial` block's local | **`logic_net`** | the law must NOT fire — residue |
| module bit-select INDEX cells (46, 54) | `rarr16[rloc16]`, `marr3_16[iloc16]` | **`logic_net`** on the INDEX | the law must NOT fire — residue |
| r10 | size = `farr16[floc16]`, a **bit-select** in a PACKAGE class's OOB method | BARE | **CONVERTED** |
| r11 / r12 | a **conditional**, a **`$bits`** system call over a local | BARE | **CONVERTED** |
| r13 | `fs16.len()` on a formal | BARE (both) | same |
| r14 / r43 / r47 | a package var / a module var | bound | same |

**r24/r25 is why the home walk goes PAST `ClassType`.**  The first cut stopped
at the class and read "home is a class -> suppress", which made those two cells
`MOVED-STILL-WRONG`: Surelog's ELABORATION invents an implicit net in the module
for every name the `new[...]` walk failed to resolve and binds the ref to THAT,
so in a module home there is no bare copy anywhere for the law to match.  The
shipped gate therefore walks StatementBlock -> Subroutine -> ClassType up to the
DEFINITION and admits only `Package` and `CompilationUnit`.

### a1 `a1_newgrid16.sv` — the same package classes in a design that HAS a module
`-- MOVED-STILL-WRONG=14 residue=6 same=28`, **0 OVER-FIRE.**  Reported, not
hidden: with a top module present golden emits each package-routine site TWICE —
a DEF copy that is BARE and an ELAB copy bound to the module's implicit net.
The patch makes both copies bare, so the DEF copy becomes correct and the ELAB
copy trades one wrong value for another.  It cannot break an equality, because
golden's `logic_net` and our `int_var` already disagreed there; it is residue
**R1** below.  The MODULE-homed cells (u10/u11 at 151/152, the `initial` at
142/144) stay `residue`, i.e. **untouched**, which is the point of a3.

## 4. THE CENSUS, AND THE MOVER PREDICTION MADE BEFORE THE SWEEP

`r10buvm16cen.cpp` reads a `.uhdm` out of `Serializer::AllObjects()` (never dump
TEXT) and prints one row per `method_func_call` named `new` / `super.new`: the
site, the call's **own VpiParent kind** (`par=NONE` is the dynamic-array form,
`par=assignment` the class form), the enclosing routine, and **every ref in the
WHOLE argument subtree** with its `Actual_group`.  `cenall16.sh` runs it over
every database in a `verify_golden` workdir on BOTH sides; `cenjoin16.py`
multiset-joins them.

**TWO KEYING TRAPS WERE PAID FOR HERE, and both are encoded in the scripts.**

1. `builtin.sv`.  Both sides carry the built-in class preamble and its spans
   OVERLAP the arm's line numbers, so "tightest containing span wins" attributed
   15 of a1's 71 cells to `builtin.sv` on one side only.  Spans from
   `builtin.sv` are now excluded from the index on both sides.
2. **THE FILE IS NOT A SOUND KEY, and this one nearly cost the prediction.**
   Our expression nodes carry an EMPTY `VpiFile`, so the census recovers the file
   from a line-containment index, and in a multi-file design that index answers
   differently on the two sides (golden `uvm_factory.svh` vs ours
   `uvm_reg_cbs.svh` for one and the same `new[m_packed_size]`).  File-keyed,
   **270 real bind rows fell into ARITY buckets and read as "no disagreement"**,
   and the first cut of this pass predicted **2** mover databases.  The join now
   keys on `line:col` **plus the argument SHAPE** (`sh=` — every argument's kind
   and name and every nested ref's name@loc, which is identical on both sides),
   which separates two files that share a line number, and the honest prediction
   is **9**.

`/tmp/r10buvm16_prediction.txt` was written from the PRISTINE censuses alone,
before the patched sweep or byteverify were read:

| corpus | predicted movers |
|---|---|
| surelog | `default`+`testflags` × `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM`, plus `default/Scoreboard` (its `testflags` row is `SLANG_REJECT` — no database) = **9** |
| uhdm2rtlil | **ZERO.**  The corpus contains exactly FOUR `new` census rows and all four are the zero-argument class `new()` in `OneThis`; there is no dynamic-array `new[...]` anywhere in it. |

`byteverify.sh` reported **exactly those 9 databases and no others** out of 956,
and **0 / 1358** on u2r.

**THE POPULATION THE LAW DOES NOT MOVE.**  MiniAmiq's other 28 dynamic-array
`new[...]` rows, SimpleUVM/SeqDriver/Scoreboard's other 23 each and SVSwitch's 2
sit in IN-BODY class methods, where § `classMethodNoBind` already leaves the ref
bare — firing there is a no-op.  `uvm_packer.svh:475`'s `m_packed_size` is a
CLASS PROPERTY, so the symbol half of the gate refuses it and it stays bound.

## 5. ATTRIBUTION — every mover named, to the LINE

`dumpdiff16.sh`, pristine -> patched.  Every changed side is a REMOVED
`|vpiActual:` and its target; nothing else moved.

| database | raw sides | sorted sides | content |
|---|---|---|---|
| `BuildUVMPkg` (both modes, identical) | 26 | **26** | 12 removed actuals + the 2 workdir-path header lines: `get_packed_bytes::sz` 22227, `get_packed_ints::sz` 22244, `get_packed_longints::sz` 22261, `get_physical_addresses_to_map::bus_width` 76163, `io_decl(n_bytes)` 76156, `array_var(local_addr)` 76165 — each ×2 copies |
| `MiniAmiq` (both modes) | 50 | **50** | 24 removed actuals ×2: `uvm_packer::get_bytes::sz` 485, `get_ints::sz` 507, `uvm_reg_map::get_physical_addresses::{local_addr 1408, n 1424, n 1484}`, `io_decl(addr)` 1405 — each ×4 copies |
| `SeqDriver` (both modes) | 90 | **50** | the same six names ×4.  The extra 40 raw sides are the campaign's documented `vpiTaskFunc` ORDER COIN; attributed ORDER-BLIND, as the measurement laws require |
| `Scoreboard` (default) / `SimpleUVM` (both modes) | 26 | **26** | the same six names ×2 |

## 6. THE GATES

| gate | result |
|---|---|
| 1 build both, md5 | `0b03a633a9020a3cb7f26346ff6d22d4` pristine / `f37116e36f261e4dfbe1b728938e84da` patched.  Both frozen at `/tmp/r10buvm16_bin/` BEFORE any sweep; every workdir's `cmds.txt` re-read and asserted to name only that binary. |
| 2 goldens | patched **23 PASS / 0 FAIL**, pristine **23 / 0**, and `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control), each with `SLANG_UHDM` exported explicitly |
| 3 u2r, `--mode both` | **0 differing ROWS** vs the pristine sweep taken first in this worktree; **679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`** in both modes; dump column unmoved |
| 4 surelog, `--mode both` | **0 differing ROWS** vs the COMMITTED `results/golden_surelog.csv`, over all **1588** rows, status AND dump.  **NO ROW CONVERTED.**  (The pristine sweep is also byte-identical to that baseline, so there is no drift to report this pass.) |
| 5 byteverify | 9 / 956 surelog, **all 9 predicted BY NAME first**; 0 / 1358 u2r; `SELFCHECK` 955/956 |
| canaries | `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0`; `canaries.sh` `ok=52 changed=0` (surelog) and `ok=16 changed=0` (u2r); `ctcan2.sh` `ok=58 changed=0` / `ok=2 changed=0`.  `SVSwitch` `4842211c4030` and `YosysVerx` `6ccda350c24a` hit exactly; `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical in both modes. |
| determinism | `detcheck.sh` 3 runs on the BuildUVMPkg input: **1 distinct hash**, 0 NO_OUTPUT |

## 7. R0 — THE NEW HEAD, DECODED, AND IT IS NOT A REGRESSION

```
LHS:
byte_var: (uvm_pkg::uvm_packer::get_packed_bytes::i), id:191859, line:22233:20, endln:22233:21
|vpiParent:
\_foreach_stmt: (uvm_pkg::uvm_packer::get_packed_bytes), id:11223, line:22233:4, endln:22233:11
…
RHS: <null>
```

The singular arm's FIRST half (`lhs != nullptr && rhs == nullptr` ->
`m_failedLhs = lhs`), so **golden carries a singular field we leave null** —
`ref_obj::Actual_group` again, the exact mirror of the head this pass cleared.
Located in both dumps: `uvm_pkg.sv:22234` `if (i != sz-1 || …)` and `:22238`
`stream[i] = v;`, where `i` is the FOREACH loop variable declared by
`foreach (stream[i])` at 22233:20.

**IT IS A DEF/ELAB SPLIT.**  In golden's DEF copy those two `ref_obj (i)` are
BARE — and ours are bare too, so the def view agrees.  In golden's ELAB copy
they carry `|vpiActual: \_byte_var (…get_packed_bytes::i)`; ours stay bare.
Golden mentions the name 15 times to our 11; the four extra mentions are exactly
those two actuals in the elab copy.

**It is not a regression.**  The pristine dump leaves the same two refs bare in
the same elab copy; R0 was simply MASKED by the head this pass cleared.

## 8. RESIDUES THIS PASS MEASURED AND DID NOT TOUCH

* **R1 — the ELABORATED IMPLICIT NET.**  When a design has a top module,
  Surelog's elaboration creates a `logic_net (work@<top>.<name>)` for every
  name a `new[...]` failed to resolve and binds the elab copy's ref to it.  That
  is the whole of the census's residual **10 disagreeing rows** (SimpleUVM, both
  modes, 5 sites) and of a1's 14 `MOVED-STILL-WRONG` cells.  We model no such
  net for a subroutine-scope name, so those copies stay bare.
* **R2 — the ELABORATED `new[...]` IS PARENTED.**  In MiniAmiq / Scoreboard /
  SeqDriver golden emits FOUR copies of each site: two unparented (this law's)
  and two `par=assignment` whose refs golden binds.  We emit four unparented.
  A CALL-PARENT disagreement, not a binding one.
* **R3 — a folded `$bits` size.**  `uvm_pkg.sv` 58275 / 58302
  `new[$bits(m_data)](__array)`: golden folds the size to a `constant`, we emit
  a `sys_func_call`.  Nothing to do with binding; both sides' refs already agree.
* **R4 — the loc-less `new()` count.**  `BuildUVMPkg` has 154 zero-argument
  class `new()` calls in golden and 156 in ours.
* **R5 — census file attribution.**  120 ARITY keys remain in the surelog join;
  they are the golden-vs-ours file disagreement described in § 4, not bind rows.

## 9. FILES

| file | what it is |
|---|---|
| `r10buvm16cen.cpp` / `build16.sh` | the `new`-call / argument-bind census instrument |
| `cenall16.sh` / `cenjoin16.py` | corpus-wide census + shape-keyed multiset join |
| `a1_newgrid16.sv` / `a2_pkgonly16.sv` / `a3_homes16.sv` / `grid16.sh` | the three arms and the three-way cell table |
| `sweeps16.sh` / `ct16rows.sh` | the sweep driver and the whole-row gate |
| `byteverify.sh` / `dumpdiff16.sh` / `rowheads.sh` / `detcheck.sh` | mover attribution, head measurement, determinism |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its audit |

---

## 10. THE ADVERSARIAL VERIFICATION (r10vbuvm16) — VERDICT: **ACCEPT**

Fresh worktrees `/tmp/wt_vbuvm16` + `/tmp/wt_vbuvm16pris` at `89bfd8f`, both
binaries rebuilt from scratch at `-j 2`, frozen read-only at
`/tmp/vbuvm16_bin/{pristine,patched}` BEFORE any sweep, every `cmds.txt`
re-read.  Both md5s reproduce EXACTLY (`0b03a633…` / `f37116e3…`), as does the
deliverable's own md5 (`ae42e0be…`) and its clean application to a FRESH
`89bfd8f`.

### Reproduced bit-for-bit
* heads: `BuildUVMPkg` **31 → 29** lines, 1 head, both modes; pristine cmp md5
  `d5d67489da8f`, patched `16780a99e816`; the other **ten** cmp logs of the
  seven-row set byte-identical between binaries.
* HEAD DECODE re-derived from the PRISTINE log and from the SOURCES, not from
  this write-up: `BaseClass.h:187-199` singular `SafeCompare` sets
  `m_failedRhs = rhs` (the VALUE) on `lhs==nullptr`; `ref_obj.cpp:150` is the
  ONLY singular `SafeCompare` in `ref_obj::Compare` and its argument is
  `Actual_group()`.  Pristine head `LHS <null> / RHS int_var(…get_packed_bytes::sz)`,
  patched head `LHS byte_var(…get_packed_bytes::i) / RHS <null>` = R0, the mirror.
* gate 2: goldens **23/0** patched, **23/0** pristine, `/bin/false` **0/23**.
* gate 3: u2r `--mode both` **0 differing ROWS** pristine→patched AND **0**
  against the committed testflags-only `results/gate_uhdm2rtlil.csv`;
  679 / 50 / 2 both modes; dump histogram unmoved.
* gate 4: surelog `--mode both` **0 differing ROWS** over all **1588** against
  the COMMITTED `results/golden_surelog.csv`, status AND dump; the PRISTINE
  sweep is byte-identical to it too (no drift).  `BuildUVMPkg` still
  `CMP_NOTEQUAL` in both modes.  **NO ROW CONVERTED.**
* gate 5: byteverify **9 / 956** surelog and **0 / 1358** u2r, `SELFCHECK`
  955/956 and 1357/1358.  The 9 are exactly the predicted set.
* THE PREDICTION WAS RE-DERIVED INDEPENDENTLY, not merely re-read: one awk over
  the verifier's OWN pristine census — "our side binds anything under a
  `par=NONE` `new`" — returns those **9 databases and no others**.
* census: `4399 / 50` → `4439 / 10` with `--loconly`, `arity_keys=120`; the
  residual 10 are SimpleUVM, both modes, 5 sites, ALL `logic_net` = R1.
* attribution, ORDER-BLIND: every mover is REMOVED `|vpiActual:` + target and
  **ZERO added lines** — BuildUVMPkg 24 sides = 12 actuals (`get_packed_bytes/
  ints/longints::sz`, `bus_width` 76163, `io_decl(n_bytes)` 76156,
  `array_var(local_addr)` 76165, each ×2), MiniAmiq/SeqDriver 48 = 24 actuals,
  Scoreboard/SimpleUVM 24.
* canaries: `canaudit.sh audited=29 UNCOVERED=0 FENCE-BREACH=0`;
  `canaries.sh ok=52/16 changed=0`; `ctcan2.sh ok=58/2 changed=0`;
  `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` hit exactly;
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes.
* determinism: 3 runs on the BuildUVMPkg input, **1 distinct hash**.

### THE ORDER COIN LANDED ON THE OTHER TEST
The write-up's raw side counts are RUN-SPECIFIC.  It reports `SeqDriver 90/50`
(40 raw sides of `vpiTaskFunc` order) and `Scoreboard 26/26`; this run measured
`SeqDriver 48/48` and `Scoreboard 116/24` — the SAME coin, landed the other way.
The ORDER-BLIND (sorted) numbers are identical on both runs, which is precisely
why the measurement laws forbid attributing raw sides.

### THE LAW WAS ATTACKED ON FIVE NEW ARMS — **0 OVER-FIRE**
`verify16/` (`vgrid16.sh`, an independent re-implementation of `grid16.sh` with
no hard-coded pass paths):

| arm | what it adds | verdict |
|---|---|---|
| `v1_pkgshapes.sv` | 65 golden `new` rows in a PACKAGE AND NOTHING ELSE: local, formal, property, `this.x`, `super.x`, package var, constant, operation, nested call, nested `new`, `$size`, `$bits`, class-queue `.size()`, LOCAL-queue `.size()`, two-arg `new[n](src)`, NAMED and unnamed block locals, `foreach` var, for-iterator, SHADOWING a property, struct member, bit-select, `fork`, ternary, OOB task, OOB static, package fn, package task | `residue=2 same=9 **CONVERTED=22**`, **0 OVER-FIRE** (the 2 residues are pre-existing `this.`/`super.` hier_path SHAPE gaps, `P == Q`) |
| `v2_homes.sv` | THE HOME GUARD: `$unit` fn, `$unit` CLASS, interface fn + interface class, PROGRAM fn + program class, module fn/task/class-OOB/`initial`/`final`, and a GENERATE-BLOCK function | `MOVED-STILL-WRONG=1 residue=18 same=4`, **0 OVER-FIRE**; every module-homed cell UNTOUCHED (golden `logic_net`), the `$unit` class OOB CONVERTS |
| `v3_newctl.sv` | the CONTROLS: `new(args)`, `super.new(args)`, shallow copy `new h`, constructor bodies, a class-new beside a dynamic-new | `same=3 CONVERTED=3`, **0 OVER-FIRE** — every parented `new` form byte-identical |
| `v4_edge.sv` | parameterised class, nested class, `ref` formal, `const` local, 9 var kinds, if/case/while bodies, do-while, FOUR-deep blocks incl. two NAMED, `foreach` inside them, a `with`-iterator size | `same=2 CONVERTED=11`, **0 OVER-FIRE** |
| `v5_stress.sv` | STATIC method, `static`-lifetime local, `automatic` local, post-`randomize` rand property, assoc-array index, casts, `string.len()`, `real`, self-`size()` copy, package-scope `new[4]`, VIRTUAL class OOB | `same=4 CONVERTED=12`, **0 OVER-FIRE** |

`vdump16.sh` (whole-dump, path- and id-normalised) over all five arms: every
single changed line is a REMOVED `|vpiActual:` or its target — **zero added
lines, zero span/name/parent movement**.

### THE BOUNDARY GATE — EVERY ARM IN THE TREE
`verify16/vbound16.sh` compiled **every `.sv` arm under `tools/probe/`** with
both binaries (arm list on fd 3, children `</dev/null`, `PROCESSED` asserted
against `LISTED`, scratch keyed on the arm's RELATIVE path) and compared
uhdm-dump text.  **PROCESSED=2717 == LISTED=2717, rejects symmetric (124 ==
124, no asymmetric reject), and NINE arms differ — every one of them a
`new[...]` arm**: this pass's own `a1/a2/a3`, the five `verify16/v1-v5` written
to move, plus exactly ONE pre-existing arm, `r10uvm69repro/a1_type.sv` — whose two moved cells were then measured against
golden and are the SAME `new[n]`-in-a-package-function family (golden `BARE ,,
logic_net`, pristine `io_decl ,, io_decl`, patched `BARE ,, BARE`: one of two
copies becomes correct, R1 for the other).  **Every bind-window law's arm is
byte-identical** — buvm13 `a1-a7`/`v1-v3`, buvm15 `a1/a2`/`v1-v7`, uvm88
`g88_*`/`v88_*`, uvm90 `g90_*`, uvm82, uvm91, sd*, and the `classArgBind12` /
`28` / `57` / `64` witnesses.

### DEFECTS THE VERIFIER FOUND AND FIXED (all in this directory; PRODUCTION UNTOUCHED)
1. **`a3_homes16.sv`'s shipped aggregate did not reproduce.**  `residue=5
   same=10 CONVERTED=2` re-measures as `residue=7 same=7 CONVERTED=3` — three
   times in a row, and once with THIS directory's own `grid16.sh` verbatim.
   `r10` (a bit-select size in a package class's OOB method) CONVERTS, it is not
   `same`, and the two module-homed bit-select INDEX cells are residues.  The
   table and the aggregate above are corrected; **0 OVER-FIRE is unchanged**.
2. **`sweeps16.sh` hard-coded `cd /tmp/wt_r10buvm16`** — no other operator could
   run it, and had that path survived holding a different checkout it would have
   swept the WRONG TREE while still printing `cmds.txt binary VERIFIED`.  It now
   derives `$REPO` from its own location, asserts the target IS a slang-uhdm
   worktree, and was RE-RUN end-to-end from `/tmp/wt_vbuvm16` (u2r, both modes,
   0 differing rows).
3. **The headline census figures need `--loconly`, which the write-up never
   said** and `cenjoin16.py` does not default to; the file-keyed default reads
   `4299 / 20` → `4319 / 0` on the same censuses.  Noted at the figures.
   (`grid16.sh`'s `CEN=` is now overridable too, as `cenall16.sh`'s already was.)

### RESIDUES THE VERIFIER MEASURED, RANKED (none touched)
* **R1** (largest, confirmed) — the elaborated implicit net: all 10 remaining
  census disagreements, all of `a1`'s 14 `MOVED-STILL-WRONG`, and
  `r10uvm69repro/a1_type`.
* **V1 (NEW) — the PROGRAM home and the GENERATE-BLOCK home are BARE in golden
  and still bound by us.**  `v2_homes.sv` 45/46/54 (a program function's local
  and formal, a program class's OOB method) and 92 (a function inside
  `if (1) begin : gblk2`) are golden-BARE exactly like a package's, but the home
  guard admits only `Package` / `CompilationUnit`, so the law does not reach
  them.  This is an UNDER-fire, i.e. the conservative direction — a strictly
  safe extension for a later pass, worth 4 measured cells here and 0 corpus rows
  (no corpus test has a program- or genblk-homed `new[...]`).
* **R2** the elaborated `new[...]` is parented in golden and unparented in ours.
* **R3** the folded `$bits` size; **R4** the loc-less `new()` count;
  **R5** census file attribution (the 120 ARITY keys).
