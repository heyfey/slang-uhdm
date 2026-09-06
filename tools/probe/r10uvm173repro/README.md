# r10uvm173 — § `pkgDefCallBindsOwnListing173` — **A CALL EMITTED INSIDE A PACKAGE'S *DEF* LISTING BINDS THAT LISTING'S OWN TWIN OF THE CALLEE; ONLY AN EXPLICITLY PACKAGE-QUALIFIED SPELLING IS RE-POINTED AT THE ELABORATED TWIN** — the SimpleUVM ×2 17-line head **CLEARED**, and the brief's typespec framing **REFUTED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW WAS CONVERTED**. `GOLDEN_DEFER` was never set.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `d53fbaad` |
| worktree | `/tmp/wt_r10uvm173` |
| pristine binary | md5 `fb82059559765e79eee43ee365aa4879`, built from a clean `d53fbaad` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `52a3bbc93edd57b0fb5a4a143252ef43`, frozen `chmod 555` before any sweep |
| production surface | `src/UhdmExporter.cpp` (**+92 / −0**: one gate on one pre-existing re-point loop; no behaviour outside it) |
| probe surface | `tools/probe/r10uvm173repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **17** | **40** | 1 — a **NEW head**, a different object (§8) |
| SeqDriver default / testflags | 33 | 33 | 1 unchanged, head log **byte-identical** |
| Scoreboard default | 95 | 95 | 1 unchanged, head log **byte-identical** |
| MiniAmiq default / testflags | 40 | 40 | 1 unchanged, head log **byte-identical** |
| BuildUVMPkg default / testflags | 52 | 52 | 1 unchanged, head log **byte-identical** |
| Earlgrey_0_1 default / testflags | 31 / 32 | 31 / 32 | 1 unchanged, head log **byte-identical** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |

A cmp line count going **up** on a head object that **CHANGED** is the expected
shape (RESUME §7): the count is the new head object's decompile size. The old
head object is gone from the log entirely.

Gates, all green (`GATES.r10uvm173.txt`): goldens 23 PASS / 0 FAIL and the
`/bin/false` negative control 0/23; uhdm2rtlil 679 CMP_EQUAL / 50 SLANG_REJECT /
2 SURELOG_FAIL in **both** modes with `ct8rows` **0 differing rows** against the
committed baseline *and* against this pass's own pristine control; the surelog
corpus **0 differing rows over 1588** (status column and dump column);
byteverify `SELFCHECK=1` **17 / 956** and **20 / 1358** movers, **every one
predicted BY NAME from pristine databases before the patched sweep ran**;
canaries `ok=52 changed=0` and `ok=8 changed=0`; `canaudit` PASS; the five
protected databases byte-identical, `SVSwitch` pin `4842211c4030` and
`YosysVerx` pin `6ccda350c24a` both held.

---

## 1. THE HEAD, DECODED — AND THE BRIEF, REFUTED

`HEAD.r10uvm173.txt` is the full transcript. The official head on SimpleUVM,
both modes, one `^LHS:` line, 17 cmp lines:

```
LHS: <null>
RHS:
ref_typespec: (uvm_pkg::uvm_is_match::s), id:5786
|vpiParent:
\_ref_obj: (uvm_pkg::uvm_is_match::s), id:5785, line:403:24, endln:403:25
|vpiActual:
\_string_typespec: , id:3966, line:23:50, endln:23:56
```

`LHS: <null>` with a full RHS is `BaseClass.h:191-197`'s **singular** mirror:
only `m_failedRhs` was recorded, so the object named is **OURS** and the field
is one golden leaves unset. The source is `uvm_globals.svh:403`,
`return (uvm_re_match(s, str) == 0);` inside the free package function
`uvm_is_match`; `s` at `403:24` is the function's own `string` local, and
`uvm_re_match` is the DPI-C import declared at `dpi/uvm_regex.svh:23`, whose
formal `re` owns the `string_typespec` at `23:50`.

**The brief asked for a typespec law. There is no typespec defect.**
`ct173cen.cpp` censuses every `tf_call` argument keyed by
view × home × callee × callee-kind × arg-kind × binding × declared-type, and on
the whole `uvm_is_match` / `uvm_re_match` / `uvm_glob_to_re` population the two
producers **diff to nothing** (`CENSUS.r10uvm173.txt` §A):

```
golden  DEF  403:24 TS=0   403:27 TS=0        ours  DEF  403:24 TS=0   403:27 TS=0
golden  ELAB 403:24 TS=1   403:27 TS=1        ours  ELAB 403:24 TS=1   403:27 TS=1
```

Golden and ours agree edge for edge, in **both** listings: the DEF-view body
leaves the actual bare, the ELABORATED body stamps the formal's typespec, on
both sides. The formal-typespec stamp at `ExprEmit.cpp:23440-23526` is not
firing wrongly anywhere here.

**WHAT THE JUDGE WAS ACTUALLY HOLDING.** A `LHS: <null>` head cannot say which
golden object was on the other side of the comparison — the singular
`SafeCompare` records only the side it has. `CompareContext::m_visited` is
public and is keyed on the LHS, so `ct173seed.cpp` answers the question by
seeding a candidate and re-running the official `Compare`: if the head moves,
the candidate was the partner.

```
seed golden's DEF-listing  ref_obj(s)@403:24 #82114  ->  head MOVES to the next argument (str)
seed golden's ELAB-listing ref_obj(s)@403:24 #22977  ->  head UNCHANGED
```

The judge was pairing **golden's DEF-listing `uvm_is_match` body against OUR
ELABORATED one** — two listings that legitimately differ. `func_call::Compare`
walks `vpiFunction`, so a def-listing call bound to the wrong twin drags the
whole comparison into the wrong body, and the first field that differs there
prints as this typespec-shaped head.

---

## 2. THE LAW

> **A `func_call` that lives in a package's DEF listing (`design->AllPackages`)
> binds `vpiFunction` to THAT listing's twin of the callee. Only a call whose
> WRITTEN NAME begins with `<some package of this design>::` is re-pointed at
> the ELABORATED twin (`design->TopPackages`).**

`ct173bind.cpp` prints one row per bound call — the listing the CALL lives in →
the listing the CALLEE lives in — and the law is the whole column
(`CENSUS.r10uvm173.txt` §B, SimpleUVM):

| bucket | golden | ours, pristine |
|---|---|---|
| `PKGDEF -> PKGDEF` func_call | **1014** | **1** |
| `PKGDEF -> PKGELAB` func_call | **3** | **1016** |
| `PKGELAB -> PKGELAB` func_call | 1900 | 1900 |

Golden's three exceptions are, by name, the three
`uvm_pkg::m_uvm_string_queue_join` calls the `UVM_STRING_QUEUE_STREAMING_PACK`
macro writes (`uvm_macros.svh:37`) — the **package-qualified** spelling. The
1014 golden keeps on the def twin are unqualified (`uvm_report_enabled`,
`uvm_is_match`, `uvm_split_string`, …), and so are the CLASS-qualified statics
`uvm_root::get`, `uvm_reg::get_max_size`, `uvm_reg_field::get_max_size`,
`uvm_mem::get_max_size`, which golden also keeps on the def twin. **The
qualifier that moves a call is a PACKAGE name, not any `::`.**

The same rule, read the other way round, is the referrer sets
(`ct173who.cpp`, `CENSUS.r10uvm173.txt` §D):

```
golden  DEF  uvm_is_match #60224  <- 13 func_calls, every one in the DEF listing
        ELAB uvm_is_match #812    <- 15 func_calls, every one elaborated
ours    DEF  uvm_is_match #2837   <- NOTHING
        ELAB uvm_is_match #5776   <- all of them
```

### 2.1 WHERE IT WENT WRONG, AND WHY THE OLD RULE LOOKED RIGHT

`src/UhdmExporter.cpp:4890-4923` (pre-existing) re-points **every**
package-internal `func_call` whose callee lives in an `AllPackages` listing at
the `TopPackages` twin of the same name. Its comment names its one witness:

> *A call BETWEEN package functions (`prim_util_pkg::vbits` calling
> `prim_util_pkg::_clog2`) binds the callee in the ELABORATED (top) package view
> in BOTH copies … EvalFunc.*

`Surelog/tests/EvalFunc/dut.sv:14` writes that call as
`return (value == 1) ? 1 : prim_util_pkg::_clog2(value);` — **qualified**. The
rule was read off a qualified cell and generalised to every package-internal
call, and on a package the size of `uvm_pkg` that over-fires by three orders of
magnitude. Re-measured today, EvalFunc's own cell reads `PKGDEF->PKGELAB` on
BOTH producers, before and after this pass: the gate keeps its witness.

### 2.2 THE PRODUCTION CHANGE

One gate, inside that loop, and nothing else: when the call's root container is
a package of `AllPackages` **and** its `VpiName` does not begin with
`<a package of this design>::`, the re-point is skipped and the call keeps the
def twin it was emitted with. The loop's behaviour is otherwise untouched, which
is why every non-package row in both corpora is byte-identical.

### 2.3 THE CROSS-PACKAGE ARM DECIDED THE QUALIFIER TEST

The first build tested the qualifier against the **callee's home package name**.
That is right for every own-package cell and wrong for one shape, caught by
`g173_b_cross.sv` before delivery: `tinderPkg`'s def listing calls
`flintPkg::emberCount` (qualified, another package) and — through a wildcard
import — `emberCount` (unqualified, the same function). Golden binds the
elaborated twin for the first and the def twin for the second. Our emitter
reaches the second through a wildcard-import CLONE whose home package is the
CALLER's, so the callee-keyed test read `flintPkg::emberCount` as unqualified
and moved that cell **AWAY** from golden. The written test — *does the name
begin with a package name of this design?* — carries every measured cell
(`GRID.r10uvm173.txt`, arm B, `AWAY-GOLDEN=0`).

---

## 3. THE GRID (`GRID.r10uvm173.txt`)

Four purpose-built goldens, each compiled by **Surelog** and by **both
binaries** in **both views** (`-elabuhdm` / `--elabuhdm`) — the law IS a
DEF/ELAB split and one view cannot see it. Names are deliberately unrelated to
each other and to the arm letter (an `a_t`/`b_t`/`c_t` grid is
self-confirming). Every arm's `rc` is recorded; **non-zero rc count: 0** on all
four.

| arm | what it varies | PKGDEF cells, patched vs golden |
|---|---|---|
| `g173_a_qual.sv` | the WRITTEN QUALIFIER: `tally(n)` vs `quill_pkg::tally(n)`, both spellings in one expression, from a free function, a task and a class method | **TO-GOLDEN 9, AWAY-GOLDEN 0, STILL-WRONG 0** |
| `g173_b_cross.sv` | TWO packages: qualified and wildcard-imported calls into the other package, plus own-package calls | **TO-GOLDEN 6, AWAY-GOLDEN 0, STILL-WRONG 0** |
| `g173_c_homes.sv` | the HOMES: free function, self-recursive function, task, in-class method, OUT-OF-BODY class method, class-property initializer, package-scope variable initializer | **TO-GOLDEN 22, AWAY-GOLDEN 0, STILL-WRONG 0** — patched equals golden cell for cell in BOTH views |
| `g173_d_notmove.sv` | the NEGATIVE CONTROL: module-scope subroutines, a module function calling a package function, a package class called from a module, a system call | **NO CELL MOVED**, either view |

Arm A's `def` view is the cleanest statement of the law — patched reproduces
golden's split exactly:

```
golden / patched   PKGDEF->PKGDEF   tally 18:12, tally 29:12, tally 33:9
golden / patched   PKGDEF->PKGELAB  quill_pkg::tally 23:12, 29:23, 37:9
pristine           PKGDEF->PKGELAB  all six
```

**The one multiset AWAY reading, characterised honestly.** Scored as a
*multiset* rather than as bucket membership, arm A's `elab` view reports
`AWAY-GOLDEN=1` on `tally 33:9`. It is a COPY-COUNT residue of another family:
in that view golden lists the class method `Ledger::viaMethod` **once** in the
DEF listing and we list it **twice**, on both binaries. Both of our copies now
carry golden's own binding, where pristine had one of the two right by accident.
`score173.py --setmode` scores bucket membership and reports `AWAY-GOLDEN=0`;
both numbers are printed in `GRID.r10uvm173.txt`, neither is hidden.

---

## 4. THE PREDICTION AND THE MOVER LEDGER (`CENSUS.MOVERS.r10uvm173.txt`)

`predsweep173.sh` ran `ct173bind` over **every** pristine database of both
corpora **before** the patched sweep and named the mover set:

* surelog, 956 databases scanned → **17 rows** with movers: `SeqDriver`,
  `SimpleUVM`, `Scoreboard`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1`,
  `FuncStructVal`, `EvalFuncNamed`, `PackFuncParent` (Scoreboard/testflags is
  SKIP-NOFILE, hence 17 and not 18);
* uhdm2rtlil, 1358 databases scanned → **20 rows**: `jeras_union`,
  `rp32_r5p_{alu,bru,mdu,wbu}`, `NestedCallsOfTheSameFunction`,
  `package_task_func`, `ReturnFunctionCall`, `ImportedFunctionUsesAnotherFunction`,
  `FunctionCallsFunctionWithIndexedPartSelectAsArgument`.

`byteverify.sh SELFCHECK=1` then realised **exactly those 37 databases and no
other** (17/956 and 20/1358; selfcheck 955/956 and 1357/1358 — the comparator
can see). The prediction is an UPPER BOUND per cell, not per database: on
SimpleUVM it predicted 1013 cells and 1008 moved, the five unrealised being
the class-qualified statics of §7 R1, which our emitter binds to the elaborated
twin at EMISSION time and which therefore never reach the re-point loop at all.

**Every mover scores `AWAY-GOLDEN = 0`** (`census173.sh`, span-blind multiset —
no generated `Compare` reads a span, and a macro-expanded call's
`SourceLocation` legitimately differs between the two producers):

| database | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG |
|---|---|---|---|
| SimpleUVM / Scoreboard (default+testflags) | 2016 | **0** | 17 |
| BuildUVMPkg | 1978 | **0** | 30 |
| SeqDriver / MiniAmiq | 434 | **0** | 2417 |
| Earlgrey_0_1 (both modes) | 98 | **0** | 0 |
| the 10 uhdm2rtlil tests | 2 – 14 each | **0** | 0 |

(`STILL-WRONG` counts cells wrong on BOTH binaries — the pre-existing
listing-copy-count family; this pass neither creates nor removes one.)

**THE DUMP IS BLIND TO THIS LAW.** A path-normalised, order-blind
(`sort`ed) `uhdm-dump` diff of pristine vs patched reads **0 lines** on
SimpleUVM (1 103 790 lines), MiniAmiq (1 890 662) and Scoreboard/default
(1 100 350): the two twins of a subroutine print identical text, so re-pointing
`vpiFunction` from one to the other changes no dump line while changing the
database bytes and the official `Compare`. `byteverify.sh` and `ct173bind`
(which read pointers) are the only instruments that see it — and for
Scoreboard/default, whose ~50/50 listing-order COIN makes a byte hash
unattributable on its own, the order-blind dump reading 0 lines is exactly the
attribution RESUME §9 asks for: the byte move is the law's pointer re-point and
nothing else.

---

## 5. THE BOUNDARY (`BOUNDARY.r10uvm173.txt`)

`bound173.sh` compiles **every** `.sv`/`.v` in a COPY of the whole committed
probe tree — top level **and** subdirectories — in **both** views with both
binaries, asserts `PROCESSED == LISTED`, keys its scratch on the RELATIVE path
(three arms in that tree are all named `dut.sv`), gives every child
`</dev/null` and reads the file list on fd 3. This pass's own `g173_*.sv` are
the positive control: a gate that reports zero movers over them cannot see.

The four slang-fenced tests the brief protects are `FENCED=` skips only: **zero**
files in the arm tree match any of their names, none was dispatched by any driver
here, and `canaudit.sh` reports `FENCE-BREACH=0`.

```
LISTED=4811  PROCESSED=4811  PRODUCED_DBS=4654  MOVED_ARMS=153  RC_DIFFS=0
```

All 153 movers were rebuilt against a **fresh Surelog golden** by
`armjudge173.sh` and scored (row-by-row verdict in `BOUNDARY.r10uvm173.txt`):

* **the official `uhdm-cmp` line count GREW on 0 of the 151 rows that have one**,
  and SHRANK on two — `r10buvm8repro/vfwd8.sv` went **17 → 0**, i.e. that arm
  became cmp-EQUAL, and `r10v169repro/v169_o_nonparam.sv` **50 → 48**;
* 136 rows score `AWAY-GOLDEN=0` outright; 13 score a multiset `AWAY`, and
  **11 of those 13 go to `AWAY-GOLDEN=0` on bucket membership** — they are the
  copy-count residue of §7 R3: where our listing carries a body twice, both of
  our copies now bind the twin golden binds, and the pristine binary had one of
  the two right by accident;
* **two rows do not, and they are one open sub-rule, recorded rather than
  dressed up** — §7 R4;
* 4 rows are `EMPTY-GOLDEN` and are reported, not swallowed (two produce no
  Surelog database at all; two moved a cell golden does not have — see
  `BOUNDARY.r10uvm173.txt`).

---

## 6. WHAT THIS PASS DELIBERATELY DID NOT DO

* **The `task_call` half of the same law.** Golden's SimpleUVM task rows are
  `PKGDEF->PKGDEF` 5 and `PKGELAB->PKGELAB` 16 — the same same-listing rule with
  no exceptions. Ours are 4 / 1 / 5 / 11: the `uvm_wait_for_nba_region` calls all
  bind the DEF twin from both listings, and `uvm_phase::m_run_phases` binds the
  elaborated one from the def listing. Six cells. The re-point loop this pass
  gates handles `func_call` only, so fixing them means ADDING a re-point rather
  than gating one — a different change with a different blast radius, and it is
  R1 below, decoded and measured, not shipped on the back of this one.
* **Un-hanging any typespec.** The brief's law was measured and REFUTED (§1);
  building it would have moved cells that already agree with golden.

---

## 7. RESIDUES

* **R1 — THE FIVE CLASS-QUALIFIED STATICS, AND THE TASK HALF.** After the patch
  SimpleUVM's def listing still binds `uvm_reg::get_max_size` (1084:22),
  `uvm_reg_field::get_max_size` (1086:11, 1087:21) and `uvm_mem::get_max_size`
  (1089:11, 1090:21) to the ELABORATED twin where golden keeps the def one.
  These are not a gate failure: our emitter binds them to the elaborated twin at
  EMISSION time (`ExprEmit.cpp:22158-22164`, `siTf` / `pkgElabSubTf`), so
  `callee->Instance()` is already a `TopPackages` object and the re-point loop
  `continue`s before the gate is reached. The same site owns the six `task_call`
  cells of §6. **R1: the `siTf` twin choice inside `emitPackage` must follow the
  listing being emitted, exactly as the re-point loop now does.**
* **R2 — THE `uvm_hdl_concat2string` SPAN.** Golden's four def-listing calls sit
  at `150:52 / 151:21 / 151:29 / 152:21`, ours at `2089:60 / 2090:29 / 2749:37 /
  2750:29` — a cross-macro-buffer `SourceLocation` of exactly the kind RESUME §9
  warns about. `Compare` reads no span; both sides now hold four `PKGDEF->PKGDEF`
  cells for that name.
* **R3 — THE ELABORATED LISTING'S COPY COUNT.** In the elab view our DEF listing
  carries a class-method body twice where golden carries it once (arm A, §3;
  `r10uvm170repro/g170_a_spell.sv` golden 20 / ours 40). A listing residue that
  predates this pass and that this pass neither creates nor removes; it is why
  11 boundary rows read a multiset `AWAY` and a bucket-membership `AWAY=0`.
* **R4 — GOLDEN SPLITS A DUPLICATED DEF-LISTING CALL BETWEEN THE TWO TWINS.**
  The two boundary rows that stay `AWAY` on bucket membership say the same thing:
  where golden's OWN def listing carries a call twice, it binds **one copy to the
  def twin and one to the elaborated twin** —
  `r10v170repro/v170_r_copies.sv` `tapR5 15:5` (and 16:5, 20:5, 21:5) and
  `r10v169repro/v169_o_nonparam.sv` `f_ko169 18:42`. We put both copies on one
  twin: the elaborated one before this pass, the def one after. The official cmp
  does not grow on either arm (1334 → 1334; **50 → 48**), no corpus row moves, and
  the discriminator between the two copies is not decoded. **R4: which copy of a
  twice-listed def-listing call takes the elaborated twin.**
* **R5 — A DEF-LISTING CALL GOLDEN DOES NOT HAVE.** `r10vbuvm31repro/gv31a5.sv`:
  our def listing carries the package-variable-initializer call
  `int pd_c[] = '{pf5(), 2}` where golden's carries none, so the cell this pass
  re-points is one-sided. cmp 250 on both binaries, unchanged.

## 8. R0 — THE NEXT HEAD

**SimpleUVM ×2, 40 lines, ONE head, the SAME object in both modes** (the two
head logs differ only in ids). It is a `VpiType` mismatch — `BaseClass::Compare`'s
first test — so both sides print in full, and it is now reachable precisely
BECAUSE the def listings are paired correctly:

```
LHS  sys_func_call ($bits) @731:34-731:39
       |vpiArgument \_ byte_var (uvm_pkg::uvm_packer::pack_bytes) @731:40-731:44
RHS  constant  @731:34-731:45  |vpiDecompile:8 |vpiSize:64 |UINT:8 |vpiConstType:9
```

`uvm_packer.svh:731`, `int max_size = value.size() * $bits(byte);`, in the
out-of-body method `uvm_packer::pack_bytes` as the package's **DEF listing**
carries it. `$bits` sits at `731:34` and its argument, the TYPE KEYWORD `byte`,
at `731:40-731:44`. Golden keeps the whole thing **symbolic** — a
`sys_func_call ($bits)` whose `vpiArgument` is a `byte_var` (Surelog's rendering
of a type operand; its `vpiFullName` is synthesized from the parent, hence the
misleading `uvm_pkg::uvm_packer::pack_bytes`) — where we FOLD it to
`constant 8, vpiSize 64, UINT`. **R0: `$bits(<type keyword>)` in a package's DEF
listing stays a `sys_func_call` over a variable of that type; the fold is an
elaboration step.** The mismatch is `VpiType`, `BaseClass::Compare`'s first
test, which is why both sides print in full.

## 9. HOW TO REPRODUCE

```bash
# the probes
for f in ct173bind ct173cen ct173own ct173seed ct173who; do
  g++ -O2 -std=c++17 $f.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/$f
done

# the head decode (needs a SimpleUVM workdir from verify_golden --filter SimpleUVM)
/tmp/ct173own  <golden.uhdm> <ours.uhdm> uvm_is_match
/tmp/ct173seed <golden.uhdm> <ours.uhdm> 82114     # the pairing prover

# the law's census, one database
/tmp/ct173bind <db.uhdm> [--rows]

# one grid arm, both views, on two binaries, then score it
CT173BIND=/tmp/ct173bind bash grid173.sh g173_a_qual.sv <pristine> <patched> <workdir>
python3 score173.py <workdir> --only PKGDEF --list          # multiset
python3 score173.py <workdir> --only PKGDEF --nospan        # span-blind

# predict the movers from PRISTINE databases, before touching anything
bash predsweep173.sh <pristine verify_golden workdir> /tmp/PRED.txt /tmp/ct173bind

# score the movers against golden
bash census173.sh <pristine workdir> <patched workdir> <outdir> SimpleUVM SeqDriver ...

# the boundary, and the verdict on every arm it moves
PRIS=<pristine> PATCHED=<patched> bash bound173.sh <copy of tools/probe> /tmp/bnd
PRIS=<pristine> PATCHED=<patched> bash armjudge173.sh /tmp/bnd/MOVERS <copy of tools/probe> /tmp/aj
```
