# r10uvm139 — § `tfItemLocalAutomaticIsNotWrittenStatic139`

**The head cleared.**  MiniAmiq **and** SeqDriver, both modes, 58 cmp lines and
one `^LHS:` at base `c3e9fee` (re-measured on THIS worktree's own pristine build
with `rowheads.sh` before a line of code was written — `head_pris_*.cmp`):

```systemverilog
function void uvm_component::m_set_cl_verb;   // uvm_component.svh:3375
  static string values[$];                    // :3380   <- THE HEAD
  static bit    first = 1;                    // :3381
  string        args[$];                      // :3382
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();   // :3383
```

```
LHS (golden)                                    RHS (ours)
string_var: (…::m_set_cl_verb::values)          string_var: (…::m_set_cl_verb::values)
|vpiName:values                                 |vpiName:values
                                                |vpiAutomatic:1     <- the ONLY differing line
```

`variables::Compare` reads the flag (UHDM's generated `variables.cpp:256`,
`lhs->VpiAutomatic() == rhs->VpiAutomatic()`); it reads neither the span nor
`VpiParent`, so the whole head was that one stamp.

**Head after:** MiniAmiq ×2 and SeqDriver ×2 **58 → 26**, still exactly one
`^LHS:`, on a NEW object — `class_typespec 'uvm_cmdline_processor'` at
`uvm_component.svh:3383`, where golden carries `vpiName` **and**
`vpiInstance -> package uvm_pkg` and ours carries neither (R0 below;
`head_pat_*.cmp`; both modes byte-identical on both rows).  Every other row's
head is unchanged: SimpleUVM 32, Scoreboard/default 32, BuildUVMPkg 32,
Earlgrey_0_1 17 / 17, Rggen/default 0.

---

## 1. The decoded model (Surelog, read line by line)

Surelog compiles a subroutine's DECLARATION SECTION in one of two places, and
the two stamp `vpiAutomatic` by **different rules**:

| production | Surelog site | the rule |
|---|---|---|
| **TF-ITEM** | `CompileHelper::compileTfPortDecl`, `CompileStmt.cpp:1576` | `bool is_static = false` at `:1663`, set true ONLY at a `paLifetime_Static` node (`:1670-1673`), then `var->VpiAutomatic(!is_static)` at **`:1690`** for every declarator |
| **BLOCK-ITEM** | `CompileHelper::compileDataDeclaration`, `CompileStmt.cpp:1127` | `automatic_status = false`, set true ONLY at `paLifetime_Automatic`, written at `:1196` |

The tf-item arm **never looks at an initialiser**, never looks at the declared
type, and never looks at the SUBROUTINE's own lifetime.  It is a pure
transcription of the WRITTEN lifetime keyword, inverted.

Our exporter already names the production selector: `blockItems9` in
`TaskFuncEmit.cpp` (a FUNCTION takes the block shape iff its header carries a
port-list paren; a TASK takes it unless the body declares io).  What it did NOT
transcribe was the rule on that face — it stamped

```cpp
if (!hasInit && !blockLocal && !blockItems9)   // pristine
    v->VpiAutomatic(true);
else if (<`automatic` keyword written>)
    v->VpiAutomatic(true);
```

i.e. **automatic unless there is an initialiser**, with the written `static`
ignored entirely.  Two independent defects, both live in the head's own
function:

* `static string values[$]` (`:3380`) — written `static`, no initialiser: ours 1, golden 0. **The head.**
* `uvm_cmdline_processor clp = …` (`:3383`) — initialiser, no keyword: ours 0, golden 1. **The head after fixing only the first** (measured on the pristine databases before any code was written).

### The law

> **§ tfItemLocalAutomaticIsNotWrittenStatic139.**  A subroutine local compiled
> under the **TF-ITEM** production carries `vpiAutomatic` **iff the `static`
> keyword is NOT written on its data declaration** — Surelog's
> `var->VpiAutomatic(!is_static)`.  An initialiser is irrelevant; the declared
> KIND is irrelevant; the SUBROUTINE's own written lifetime (`function static`,
> `function automatic`, `task automatic`) is irrelevant.  The BLOCK-ITEM
> production keeps the opposite rule — automatic iff `automatic` is WRITTEN
> (§ `blockDeclAutomaticIsWrittenKw80` in `StmtEmit.cpp`, § `r10fsv3` here) —
> and is untouched.

Probe-verified on golden, both views.  `g139_b_kinds.sv`, one paren-less
function holding one local of every declaration kind, three written lifetimes,
with and without an initialiser:

| written on the declaration | int / logic / bit / real / enum / packed-struct / typedef'd / byte / shortint / longint / time / integer / reg / string-queue / dynamic array / fixed array / associative array / class handle |
|---|---|
| nothing | `vpiAutomatic:1` on **every** kind |
| `static` | **absent** on every kind |
| `automatic` | `vpiAutomatic:1` on every kind |
| nothing **+ an initialiser** | `vpiAutomatic:1` |
| `static` **+ an initialiser** | absent |

and the BLOCK production of the same file (`blkKinds139`, the identical
declarations under `function void blkKinds139();`) reads **0 / 0 / 1** for the
same three spellings — the other rule, unchanged by this pass.

`g139_a_homes.sv` puts the same three spellings in fourteen HOMES.  Golden's
answer is the production, never the home and never the subroutine's lifetime:

| home | header | golden, none / `static` / `automatic` |
|---|---|---|
| in-body class method | `function void f;` | 1 / 0 / 1 |
| in-body class method | `function void f();` | 0 / 0 / 1 |
| in-body class task | `task t;` | 0 / 0 / 1 |
| in-body class task **with a body io decl** | `task t; input int …;` | 1 / 0 / 1 |
| in-body class method | `function automatic void f;` | 1 / 0 / 1 |
| STATIC class method | `static function void f;` | 1 / 0 / 1 |
| out-of-body class method (both listings) | `function void C::f;` | 1 / 0 / 1 |
| package free function | `function void f;` / `function void f();` | 1 / 0 / 1 and 0 / 0 / 1 |
| package function, explicit `function static void f;` | | 1 / 0 / 1 |
| package task / package task with io | | 0 / 0 / 1 and 1 / 0 / 1 |
| interface function | both headers | 1 / 0 / 1 and 0 / 0 / 1 |
| program function / program `initial` block | | 1 / 0 / 1 and 0 / 0 / 1 |
| module function / task / task-with-io | | 1 / 0 / 1, 0 / 0 / 1, 1 / 0 / 1 |
| generate-block function | `function void f;` | 1 / 0 / 1 |
| module `initial` / `always` / `fork…join_none` block locals | | 0 / 0 / 1 (block rule) |

### What Surelog does NOT emit at all

Under the TF-ITEM production a `const` or `var`-modified declaration produces
**no variable object in golden**: `fC->Child(Data_declaration)` is the
`const`/`var` node, the lifetime test misses, and `Data_type` is taken off the
wrong node.  Under the BLOCK production a `var` declaration is reported
`[ERR:UH0701] Unsupported statement` and dropped, while `const` survives with
`vpiConstantVariable`.  We emit objects for all of them.  That is a
**pre-existing ONLY-OURS residue, not this law's** — recorded in R3, measured on
`g139_c_shapes.sv`, and its corpus incidence is ZERO (the predictor names no
such cell in 1573 + 1462 rows).

---

## 2. What shipped

`src/TaskFuncEmit.cpp` only — one file-local helper and a six-line rewrite of
the stamp, no header change, no new exporter state:

* `WrittenLife139` / `writtenLife139(const Symbol&)` — reads the lifetime
  keyword off the `Declarator`'s parent `DataDeclarationSyntax`, so a
  MULTI-DECLARATOR declaration (`static int a, b;`) answers `Static` for every
  declarator, which is what Surelog does (the keyword is read once, off the
  shared declaration node, and `!is_static` is written on each
  `Variable_decl_assignment`) — measured on `g139_c_shapes.sv`
  `w1..we` / `x1..xa`;
* at the stamp: `if (!blockLocal && !blockItems9) { if (life != Static) v->VpiAutomatic(true); }
  else if (life == Automatic) v->VpiAutomatic(true);`

The `else` arm is § `r10fsv3` **verbatim** — same predicate, same effect — only
re-expressed through the shared helper; the `hasInit` term moved OUT of the
selector, which is the whole behavioural change together with the `Static` test.
Cell by cell, against the pristine code:

| tf-item face | pristine | patched | golden |
|---|---|---|---|
| no keyword, no init | 1 | 1 | 1 |
| `automatic`, no init | 1 | 1 | 1 |
| **`static`, no init** | **1** | **0** | **0** |
| **no keyword, with init** | **0** | **1** | **1** |
| `automatic`, with init | 1 | 1 | 1 |
| `static`, with init | 0 | 0 | 0 |
| block face (any) | unchanged | unchanged | — |

---

## 3. The a-priori prediction (question 2/3, over all 956 + 1358 databases)

`PREDICTION.txt` was written **before the patched sweep was read**, from a
PREDICTOR binary: the PRISTINE emitter plus one `fopen`/`fprintf` that is inert
unless `PRED139` names a file (`pred139.diff` carries the exact text).  Its
databases are byte-identical to the pristine binary's — verified md5-for-md5 on
MiniAmiq's own command line at the SAME output path (a database embeds the `-o`
path, so two different paths differ for that reason alone).  It reports, from
the OLD code path, every cell whose flag the new rule would change.

`predsweep139.sh` replays every row of a completed pristine sweep workdir with
that binary, from the row's OWN source directory (`verify_golden.py` runs slang
with `cwd=<the test's dir>` and names the workdir `<test>-<sha1(dir)[:8]>`;
`cmds.txt` does not record the cwd, so the driver reconstructs it by indexing
every corpus directory by that same hash — a row whose cwd cannot be recovered
is REPORTED, never silently skipped).

```
surelog    LISTED=1573 PROCESSED=1573 ROWS-WITH-CELLS=9
uhdm2rtlil LISTED=1462 PROCESSED=1462 ROWS-WITH-CELLS=0
```

Every row that produced a pristine database ran the predictor to completion
(rc 0, or rc 4 = warnings only); rows at rc 1/2/3/139 produce no database at
all, so the prediction covers the whole comparable population.

**The predicted mover set — nine rows, and the whole population is FOUR written
sites in one file:**

```
uvm_component.svh:3380   static string values[$]                  1 -> 0
uvm_component.svh:3383   uvm_cmdline_processor clp = …            0 -> 1
uvm_component.svh:3539   static bit initialized                   1 -> 0
   (1800.2's pp_output spells the same three at 41169 / 41172 / 41351 and adds
    m_set_cl_action's and m_set_cl_sev's `uvm_cmdline_processor uvm_cmdline_proc = …`
    at 41266 / 41353, also 0 -> 1)

  SeqDriver default/testflags   12 cells    (uvm_pkg + svaunit_pkg, x2 views)
  MiniAmiq  default/testflags   12 cells
  SimpleUVM default/testflags    6 cells
  Scoreboard default             6 cells
  BuildUVMPkg default/testflags 10 cells
```

`byteverify.sh SELFCHECK=1` on the patched sweep then reported **MOVERS 9 / 956,
precisely those nine rows and no others**, and **0 / 1358** on uhdm2rtlil.

### The scored census

`ct139cen.cpp` walks every `variables` object the `UhdmListener` reaches
(deduped by `UhdmId`) and prints `AUTO VKIND VNAME VTS VCONST` plus the
dump-only `PATH VFULL VSPAN`; `score139.py` joins golden / pristine / patched as
a MULTISET on the id-free key `SCOPE|VNAME`, ordered within a key by `PATH`.
Neither a SPAN nor the PARENT chain is in the key: the two producers disagree
about both on exactly this population (an initialised tf-item local anchors at
the declared type and hangs off the subroutine in golden; here it anchors at the
name, and a PACKAGE free function re-parents it under the body `begin`'s init
assignment), and `variables::Compare` reads neither — a span or a parent in the
key would SPLIT cells the judge pairs.  Both are scored as separate dump-only
columns instead.

The key **calibrates clean golden-vs-golden on every row**: `ONLY-GOLDEN 0`,
`ONLY-OURS 0`, `AWAY 0` (MiniAmiq 17104 cells, SeqDriver 16215, BuildUVMPkg
9513, SimpleUVM 9455, Scoreboard 9476).

| row | mode | AUTO cells | **WRONG→RIGHT** | WRONG→WRONG | **RIGHT→WRONG** | AWAY |
|---|---|---|---|---|---|---|
| SeqDriver | default / testflags | 17184 / 17184 | 12 / 12 | 0 | **0 / 0** | 0 |
| SimpleUVM | default / testflags | 9459 / 9459 | 6 / 6 | 0 | **0 / 0** | 0 |
| Scoreboard | default | 9480 | 6 | 0 | **0** | 0 |
| MiniAmiq | default / testflags | 18073 / 18073 | 12 / 12 | 0 | **0 / 0** | 0 |
| BuildUVMPkg | default / testflags | 9519 / 9519 | 10 / 10 | 0 | **0 / 0** | 0 |
| **total** | | **117 950** | **86** | **0** | **0** | **0** |

**`WRONG->WRONG` is 0 in the AUTO column of all nine databases**: after this
pass every PAIRED variable in every UVM database agrees with golden on
`vpiAutomatic`.  `VKIND`, `VTS` and `VCONST` are RIGHT→RIGHT except the
pre-existing residues, which are IDENTICAL in pristine and patched (SeqDriver
`VKIND` 149, `VTS` 184; MiniAmiq 168 / 222; the smaller rows 3 / 2-4), and the
one-sided sets (`ONLY-GOLDEN` 2663 / 2621 / 49 / 35 / 17, `ONLY-OURS` 969 / 969
/ 6 / 4 / 4) are unchanged cell for cell — the key does not move, so **AWAY is
0 in every column of every row.**

---

## 4. Grids — 5 arms × {DEF, ELAB}, 1229 variable cells

`arms139.sh` runs every `g139_*.sv` under Surelog (golden), the pristine and the
patched binary in both views and scores with `ct139cen` + `score139.py` (each
arm in its OWN subdirectory keyed on its relative path; file list on fd 3;
children `</dev/null`; `PROCESSED` asserted; every rc recorded).

| arm | what it varies | view | AUTO cells | **W→R** | **R→W** | W→W |
|---|---|---|---|---|---|---|
| `g139_a_homes` | 14 HOMES × 3 written variable lifetimes × both header shapes × `function automatic` / `function static` / `static function` / `task` / `task`-with-io | def / elab | 96 / 162 | 17 / 19 | **0 / 0** | 0 |
| `g139_b_kinds` | 18 declaration KINDS × 3 lifetimes × ±initialiser, under BOTH productions | def / elab | 146 / 271 | 44 / 44 | **0 / 0** | 0 |
| `g139_c_shapes` | multi-declarator lists, `const`/`var`, nested `begin` / `for`-body blocks inside a tf-item subroutine, `task automatic` / `task static`, io+block mixed, initialised handles / enums / arrays | def / elab | 113 / 244 | 22 / 24 | **0 / 0** | 0 |
| `g139_d_mult` | 1, 2 and 3 instances of one parameterised module + a package class used from each | def / elab | 24 / 115 | 10 / 42 | **0 / 0** | 0 |
| `g139_e_carveout` | the `blockLocal` face this law does not reach (R1) | def / elab | 23 / 35 | 5 / 5 | **0 / 0** | 5 / 10 |
| **total** | | | **1229** | **232** | **0** | **15** |

`ONLY-GOLDEN` is **0 in every column of every arm-view**.  `ONLY-OURS` is 0
except `g139_b_kinds`/elab 10, `g139_c_shapes` 10 / 40 and `g139_d_mult`/elab 22
— the `const`/`var` objects golden never emits (R3) and the elaborated
instance-listing residue — all IDENTICAL in pristine and patched, so **AWAY is 0
in every column of every arm-view**, and **`RIGHT->WRONG` is 0 in every column
of every arm-view**.

Names are deliberately unalike across arms (`Quarry139`/`Chisel139`/`Sluice139`/
`Weir139`/`Gantry139`; `Forge139`/`Tongs139`; `Loom139`/`Bobbin139`;
`Anvil139`/`Hammer139`/`Rivet139`/`Press139`/`Bellows139`/`Crucible139`;
`Ladle139`/`Stile139`/`Trestle139`; index names `ka..rc`, `a1..v5`, `w1..df`,
`ea..fh`, `ca..ed`) — a grid that calls everything `a_t`/`b_t`/`c_t` over
`A`/`B`/`C` is self-confirming.

---

## 5. Boundary — 3993 files × both views

`bound139.sh` compiles every `.sv`/`.svh` under the WHOLE of `tools/probe` (3993 files) with
the pristine and the patched binary, in both views, **to the same output path**
(a database embeds `-o`), and compares the two databases by **md5 first** — a
byte-identical database needs no dump.  A file whose database MOVED must be
attributable on FOUR independent counts:

1. its `ct139cen` variable census must have moved too;
2. the **PREDICTOR** must name at least one cell for that file AND view — an
   exact predicate, the law's own decision on the old code path, not a
   syntactic proxy;
3. every moved census row must differ ONLY in the `AUTO=` field;
4. every line of the whole-dump diff must be a `vpiAutomatic` line.

```
LISTED=3993 PROCESSED=3993 MOVED=14 BREACH=0 RC-MISMATCH=0 NORUN=306
PROCESSED-ASSERT-OK
BOUNDARY PASS
```

The moved file-views are this pass's own five arms in both views (10), plus
**`r10uvm66repro/a2_slots.sv` and `a3_count.sv`**, both views — five foreign
cells, every one an initialised TF-ITEM local (`a2mod.n24_tfitems::ce`,
`a3mod.p03_tfint::x`, `p07_tfdyn::d`, `p08_tfonly::q`, `p09_tfintonly::x`).
Re-measured against GOLDEN they move **TOWARD** it and nowhere else:

| file | view | AUTO cells | W→R | **R→W** |
|---|---|---|---|---|
| `a2_slots.sv` | def / elab | 56 / 116 | 1 / 2 | **0 / 0** |
| `a3_count.sv` | def / elab | 18 / 37 | 4 / 8 | **0 / 0** |

**No other foreign arm moved**: every `r10uvm77-79` / `r10uvm82-91` /
`r10uvm113` / `r10uvm122` / `r10uvm131` / `r10uvm134` / `r10uvm137` /
`r10buvm3-15` / `r10buvm33-34` / `r10sd8-12` file is byte-identical on both
binaries in both views.  `NORUN` file-views produce no database on EITHER binary
with the SAME rc (fragments, include-only `.svh`, and pre-existing segfaults
that crash both binaries identically); `RC-MISMATCH=0` asserts pristine and
patched never disagree about running.  Positive control `CTRL=1` over this
pass's own arm directory: `LISTED=4 PROCESSED=4 MOVED=8 POSITIVE-CONTROL-OK`
(taken before `g139_e_carveout.sv` was added).  See `BOUNDARY.txt`.

The four slang-fenced tests are never dispatched and never spelled here;
`canaudit.sh canaries.sh ctcan2.sh` run from this directory reports
`audited=29 UNCOVERED=0 FENCE-BREACH=0`.

---

## 6. Gates (all green, on this worktree's OWN pinned build and workdirs)

1. **build** both binaries `-j 2`, md5 taken separately, both frozen
   `chmod 555` at immutable paths before any sweep; the committed tree rebuilds
   to the patched binary's md5 EXACTLY.  Every `cmds.txt` audited BY BINARY
   PATH (not by the string `slang-uhdm`, which also matches the golden cache):
   of 1573 surelog `cmds.txt` **1523 name the frozen binary and 50 name none at
   all** (golden-cache-only cells), and of 1462 uhdm2rtlil `cmds.txt`
   **1458 name it** — in BOTH sweeps.  **Zero cells name the main-tree binary or
   this worktree's `build/slang-uhdm`, in either corpus, in either sweep.**
2. **goldens** `SLANG_UHDM` exported explicitly to EACH binary: patched
   **23 PASS / 0 FAIL**, pristine **23 PASS / 0 FAIL**; negative control
   `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
3. **uhdm2rtlil**, testflags AND default: **679 CMP_EQUAL / 50 SLANG_REJECT /
   2 SURELOG_FAIL** in both modes (status histogram read — a rc=139 segfault
   would surface as SLANG_REJECT); `ct8rows.sh` **0 differing rows** against the
   committed `results/gate_uhdm2rtlil.csv` AND against this build's own pristine
   sweep, in both modes, status AND dump column; `byteverify.sh SELFCHECK=1`
   **MOVERS 0 / 1358** (SELFCHECK 1357/1358).
4. **surelog `--mode both`**, 1588 rows: **937 CMP_EQUAL / 567 SLANG_REJECT /
   48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE /
   2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM** — identical to pristine;
   `ct8rows.sh` **0 differing rows over 1588** against the committed
   `results/golden_surelog.csv` and against the pristine sweep.  **NO ROW IS
   CONVERTED** (MiniAmiq and SeqDriver stay CMP_NOTEQUAL at a new, unrelated
   head) and `results/*.csv` is untouched.
5. **byteverify.sh SELFCHECK=1** on surelog: **MOVERS 9 / 956**, SELFCHECK
   955/956 — precisely the nine rows `PREDICTION.txt` named a priori from the
   PRISTINE emitter, and no others.

Canaries: `canaries.sh` `ok=52 changed=0 absent=0` (surelog) and
`ok=8 changed=0 absent=0` (u2r); `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6`
`ctcan2.sh` PASS on both corpora; `canaudit.sh` PASS.  Protected databases by
name, md5 vs the pristine sweep, BOTH modes: InterfaceModPort,
BlackParrotComplex, YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx
`6ccda350c24a`.

**Mover attribution, ORDER-BLIND and NAMED** (`movers139.sh`: both dumps id- and
workdir-normalised and `LC_ALL=C sort`ed — the only sound attribution for
Scoreboard/default and SeqDriver, which are ~50/50 coins — and, beside it, a
`ct139cen` census diff whose rows carry the object's scope and name, because a
sorted multiset diff of identical dump lines reports only the NET delta):

| database | mode | net dump lines | census rows moved | rows moved outside `AUTO=` | names |
|---|---|---|---|---|---|
| SeqDriver | default / testflags | −4 / −4 | 24 / 24 | 0 / 0 | `values` `clp` `initialized` |
| SimpleUVM | default / testflags | −2 / −2 | 12 / 12 | 0 / 0 | `values` `clp` `initialized` |
| Scoreboard | default | −2 | 12 | 0 | `values` `clp` `initialized` |
| MiniAmiq | default / testflags | −4 / −4 | 24 / 24 | 0 / 0 | `values` `clp` `initialized` |
| BuildUVMPkg | default / testflags | +2 / +2 | 20 / 20 | 0 / 0 | + `uvm_cmdline_proc` |
| **total** | | **26** | **172** | **0** | |

172 census rows = 86 cells × 2 (a `<` and a `>` line each) — exactly the 86
`WRONG->RIGHT` cells the census scored and exactly the cells `PREDICTION.txt`
named.  Nothing else in any database changed.

---

## 7. Residues and R0

* **R0 (the next head).**  MiniAmiq ×2 and SeqDriver ×2, 26 cmp lines, ONE
  `^LHS:` — `class_typespec 'uvm_cmdline_processor'` at
  `uvm_component.svh:3383` (the typespec of `m_set_cl_verb`'s
  `uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();`, now reached
  because the variable's own fields agree).  Golden carries
  `|vpiName:uvm_cmdline_processor` and `|vpiInstance: -> package uvm_pkg`
  (the ELABORATED package); ours carries a NAMELESS, uninstanced
  `class_typespec` with only `|vpiClassDefn:`.  Both modes produce a
  byte-identical cmp log on both rows.  This is the same `vpiInstance` family as
  § `scopedTdUnsupTsHomePkgInstance83` and § `pkgVarBindsOnlyThroughInstance88` —
  a class-handle local's typespec inside an OUT-OF-BODY class method.
  See `head_pat_default_MiniAmiq.cmp`.
* **R1 — the `blockLocal` carve-out on the TF-ITEM face.**  `blockLocal`
  (`isEnumArr || namedTypeLocal`) suppresses the tf-item stamp for a local
  declared through a NAMED typedef in a NON-package-scoped subroutine.  Golden
  applies the tf-item rule there too: `g139_e_carveout.sv` measures 15 cells
  (5 def + 10 elab) where golden reads 1 with no lifetime written and we read 0
  — `Trestle139.mfTd139` `da` `dd` `df` `dh` and `mtTd139` `eb`.  This law
  deliberately does not fire on that face: the same predicate also drives the
  object's LOCATION and its re-parenting into the body `begin`
  (`fnBlockLocalPav`), so correcting it is a parenting law, not a flag law.
  Corpus incidence: **zero** — `namedTypeLocal` requires `!pkgScope` and the
  predictor names no such cell in 1573 + 1462 rows.
* **R2 — the initialised TF-ITEM local's SPAN and PARENT.**  Golden anchors it
  at the DECLARED TYPE and lists it on the subroutine (`clp` at
  `uvm_component.svh:3383:3`); we anchor it at the NAME (`3383:25`) and, in a
  PACKAGE FREE function, re-parent it under the body `begin`'s init assignment.
  Both are DUMP-ONLY (`variables::Compare` reads neither a location nor
  `VpiParent`) and both are IDENTICAL in pristine and patched — the `VSPAN` and
  `PATH` columns of every census and every arm read the same numbers on both
  sides.  Measured: `g139_b_kinds` 10 cells, `g139_c_shapes` 20 / 20,
  `g139_d_mult` 6 / 25.
* **R3 — `const` / `var` tf-item locals are objects golden never emits.**  Under
  the TF-ITEM production Surelog produces NO variable for `const int m = 3;` or
  `var int n;`; under the BLOCK production it reports
  `[ERR:UH0701] Unsupported statement` for `var` and drops it, while `const`
  survives with `vpiConstantVariable` (which we do not set — `g139_c_shapes`
  `z1`, 2 def + 8 elab cells).  We emit an object in every case: 10 def + 40
  elab `ONLY-OURS` cells on that arm.  This pass changes the FLAG on one of them
  (`y1`, `const int y1 = 3;`, 0 → 1) because the tf-item rule has no `const`
  clause either; it is a payload change on a cell golden does not have, not an
  AWAY.  Corpus incidence: **zero** — no corpus row declares a `const` or `var`
  local in a tf-item section (the predictor's whole corpus-wide cell list is the
  four written UVM sites, none of them `const`/`var`).
* **R4 — the OTHER production's `hasInit` gate is untested here.**  This pass
  removed `hasInit` from the tf-item selector only; the BLOCK face still reads
  it for the object's location and for `namedTypeLocal`.  Every BLOCK-face
  `AUTO` cell of every arm and every corpus row is RIGHT→RIGHT, so nothing is
  known to be wrong there.
