# r10uvm195 — § `cloneTfOwnVarListingIsUnbound195` — **A WILDCARD-IMPORT CLONE'S SUBROUTINE-LEVEL VARIABLE LISTING CARRIES NO `vpiActual`** — the SeqDriver ×2 / MiniAmiq ×2 29-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own fence list
(`predict195.sh` reads that list at run time and skips those rows, so this
pass's artifacts never spell them).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `c3e022a3` |
| pristine binary | md5 `4a42bc7a0018bc97d6d57ceebe1a0a9d`, built from this pass's OWN worktree at a clean `c3e022a3` and **byte-identical to the main tree's `build/slang-uhdm`**; frozen `chmod 555` before any sweep |
| patched binary | md5 `19a1a55b008635113366cdd8b93375ff`, frozen `chmod 555` |
| production surface | `src/UhdmExporter.cpp` (one pass at the end of the clone-binding block) and `include/UhdmExporter.h` (the law and its two producers' citations) — **+92 / −0 lines, two files, no new exporter state, no new flag** |
| probe surface | `tools/probe/r10uvm195repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default AND testflags, MiniAmiq default AND testflags: 29 cmp lines, ONE `^LHS:` each, the SAME object in all four → the object is GONE and the head is a DIFFERENT one (198 lines, R0 below).** MiniAmiq's two modes are byte-identical before (md5 `66f5a0fb…`) and after (`a013311f…`). |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND this pass's own pristine sweep. **NO ROW CONVERTED in either direction.** BuildUVMPkg ×2 and Earlgrey_0_1/testflags are `CMP_EQUAL` in both sweeps and **STAY** `CMP_EQUAL` (rowheads 0 lines / 0 heads on both binaries). |
| byte movers | **surelog 5 / 956** — MiniAmiq ×2 and SeqDriver ×2, **all four PREDICTED BY NAME from the 956 PRISTINE databases alone before the patched sweep was read**, plus Scoreboard/default, the documented ~50/50 COIN, which scores **0 order-blind diff lines**. **uhdm2rtlil 0 / 1358**, and 0 predicted. |
| the corpus population | **17 wildcard-import clone subroutines × 2 package listings = 34 cells per moving row-mode**, every one of them a `ref_var` in `adpcm_pkg`'s copy of a `uvm_pkg` subroutine, and **none anywhere else in either corpus**. |
| the census (nine UVM row-modes) | calibrated golden-vs-golden FIRST (**7522 keys, AGREE 7522, every other column 0**). **TO-GOLDEN 68, AWAY-GOLDEN 0, MOVED-WRONG 0** — 17 keys each on the four moving row-modes, 0 on SimpleUVM ×2, Scoreboard/default and BuildUVMPkg ×2. Scoreboard/testflags has no golden and is reported `SKIP-NOFILE`, never silently skipped. |
| the grid (5 arms × both views, one real Surelog golden each) | **TO-GOLDEN 42, AWAY-GOLDEN 0, MOVED-WRONG 0.** Arm E (the minimised head) goes **29 cmp lines / 1 head → 0 / 0 `CMP_EQUAL`**. Arm D, the control with no wildcard import, is **byte-identical in both views on both binaries**. |
| the WIDE boundary (5185 arms × both views) | `LISTED=5185 PROCESSED=5185 PRODUCED_DBS=5020 MOVED_ARMS=6 RC_DIFFS=0`. Four are this pass's own arms (the POSITIVE CONTROL). The other two are earlier passes' arms, rebuilt against their OWN real Surelog goldens and scored **TO-GOLDEN 2 / AWAY 0 / MOVED-WRONG 0** and **TO-GOLDEN 1 / AWAY 0 / MOVED-WRONG 0** — one of them, `r10v179repro/v179_f_nomod.sv`, carries this very head and goes **29/1 → 0/0 `CMP_EQUAL`**. |
| what the brief got wrong | its framing ("we list the process-typed local as a begin variable and golden does not") is **REFUTED by three independent instruments**; both sides list it, in both listings, at the same index. §2. |
| what was refuted along the way | a VIEW conjunct. §5. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `c3e022a3` worktree (it
came out byte-identical to the main tree's), ran its 23/23 goldens with the
`/bin/false` negative control, and reproduced both committed baselines row for
row (`ct8rows` 0 differing rows, status AND dump column, over 1588 surelog rows
and both u2r modes) before a line of code was written.

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         29      1     <- the target
SeqDriver      testflags       29      1
MiniAmiq       default         29      1
MiniAmiq       testflags       29      1
SimpleUVM      default/tf  664681      1
Scoreboard     default         95      1
BuildUVMPkg    default/tf       0      0     CMP_EQUAL
Earlgrey_0_1   default/tf      31 / 0  1 / 0 (testflags CMP_EQUAL)
Rggen          default          0      0     CMP_EQUAL
```

The head, the same object in all four row-modes:

```
LHS: <null>
RHS:
ref_var: (uvm_pkg::uvm_root::run_test::phase_runner_proc), id:96774, line:411:11, endln:411:28
|vpiParent:  \_begin: (uvm_pkg::uvm_root::run_test), id:96777, line:403:3, endln:403:51
|vpiTypespec: \_ref_typespec: -> unsupported_typespec: (process), line:411:3
|vpiName:phase_runner_proc
```

uvm-1.2 `base/uvm_root.svh:411` is `process phase_runner_proc;`, a
SUBROUTINE-LEVEL local of the out-of-body class task
`task uvm_root::run_test(string test_name="")` (`:400`).

---

## 2. DECODING THE JUDGE — THE BRIEF'S FRAMING IS REFUTED

`BaseClass.h:194-197`'s SINGULAR `SafeCompare` sets **only** `m_failedRhs` when
the GOLDEN pointer is null, so `uhdm-cmp` prints `LHS: <null>` above OUR object
and **the printed object is not the owner**. Three instruments say the listing
is not the question:

* **`ct195own`** (the MIRROR owner-finder, r10uvm164's `ct164own` form with the
  sides swapped; full output in `OWNER.pristine.r10uvm195.txt`) reports the two
  listings that hold the head as `edge vpiType=100 VECTOR[9/10]` against
  `golden vector size 10` (the `begin`) and `VECTOR[8/9]` against
  `golden vector size 9` (the `task`) — **same index, same size, both sides**.
* the uhdm-dump of golden's `begin @403:3` lists ten variables ending in
  `\_ref_var: (uvm_pkg::uvm_root::run_test::phase_runner_proc)`, entry for entry
  identical to ours.
* **`ct195list`** (`LIST.pristine.r10uvm195.txt`) enumerates every `ref_var` of
  that name in both databases and settles it:

```
GOLDEN                                              actual
#16195  uvm_pkg   /begin/task:run_test/class_defn   <null>
#75327  uvm_pkg   /begin/task:uvm_root::run_test    <null>
#134662 adpcm_pkg /task:uvm_root::run_test          <null>          <<<
#134701 adpcm_pkg /begin/task:uvm_root::run_test    ref_var #16195
#198789 adpcm_pkg /task:uvm_root::run_test          <null>          <<<
#198828 adpcm_pkg /begin/task:uvm_root::run_test    ref_var #16195
OURS
#96774  uvm_pkg   /begin/task:run_test/class_defn   <null>
#144799 uvm_pkg   /begin/task:uvm_root::run_test    <null>
#197462 adpcm_pkg /begin/task:uvm_root::run_test    ref_var #96774
#251258 adpcm_pkg /begin/task:uvm_root::run_test    ref_var #96774
```

`package adpcm_pkg; import uvm_pkg::*;` (SeqDriver `testbench.sv:10-12`) is a
**wildcard-import CLONE**. Golden holds **two** objects there — the one the TASK
lists (UNBOUND) and the one the body `begin` lists (BOUND to the home) — and we
hold **one**, listed in both, BOUND. The failing compare is therefore
`ref_var::Compare`'s `SafeCompare(lhs->Actual_group(), rhs->Actual_group())`
(UHDM `build/generated/src/ref_var.cpp:112`) on the **task-listed** slot: golden
null, ours the home `ref_var` — printed as `LHS: <null>` with our home object as
the value. **The head is a BINDING, not a listing.**

The minimal reproducer is 20 lines (`grid195/g195_e_head.sv`) and produces a
29-line, one-head cmp of exactly the same shape.

---

## 3. DECODING SURELOG AND UHDM — WHY ONE SLOT BINDS AND THE OTHER DOES NOT

1. **`CompileHelper::importPackage`**, Surelog
   `src/DesignCompile/CompileHelper.cpp:318-327`: when the importer **is a
   package** (`inPackage`), every imported task/function is `UHDM::clone_tree`'d.
   An importing module / program / `$unit` pushes the **home object itself**
   (`sfuncs->push_back(func)`, `:326`) — no clone, nothing to unbind. That is
   arm D's control, and it moves zero bytes.
2. **`task::DeepClone`**, UHDM `build/generated/src/clone_tree.cpp:611-708`,
   clones `Io_decls()` and then **`Variables()` at `:634-641`** — and only calls
   `enterTask_func(clone, …)` at **`:660`**. While the subroutine-level
   declarations are cloned the elaborator's scope stack holds **no frame for the
   subroutine at all**. `ref_var::DeepCopy`
   (`build/generated/src/ref_var.cpp:75-83`) is

   ```cpp
   if (!clone->Actual_group())
       clone->Actual_group(elaboratorContext->m_elaborator.bindAny(VpiName()));
   if (!clone->Actual_group())
       clone->Actual_group((any*) Actual_group());
   ```

   `bindAny` (`ElaboratorListener.cpp:899`) walks that stack, misses, and the
   fallback copies the SOURCE's `Actual_group` — **null on a home declaration**.
   The subroutine's own listing entry is UNBOUND.
3. `task_func::DeepCopy` (`build/generated/src/task_func.cpp:120`) then clones
   `Stmt()`. **`begin::DeepClone`** (`build/generated/src/begin.cpp:71-81`) opens
   with `enterBegin(this, …)` — on the **SOURCE** begin, whose `Variables()` are
   the HOME objects (`ElaboratorListener.cpp:1193-1213` builds the varMap from
   them) — so every body-level `ref_var` clone binds to the HOME object. The
   body listing is BOUND, which § `pkgCloneLocalRefBind37` already reproduces.

### The law

> **§ `cloneTfOwnVarListingIsUnbound195`.** In a WILDCARD-IMPORT CLONE, the entry
> of the SUBROUTINE's OWN `vpiVariables` listing carries **no `vpiActual`**.
> Only the body BLOCK's listing entry is bound to the home declaration.

Why a `process` local is a `ref_var` at all is
§ `builtinClassLocalUnsupportedBeforeClassPhase115`'s, not this law's. **This law
is KIND-BLIND**, and that was measured, not assumed: of the 17 corpus
subroutines it moves, `uvm_root::run_test::phase_runner_proc`,
`uvm_reg::XatomicX::m_reg_process` and `uvm_process_report_message::p` are
`process` locals (§ 115) while `uvm_reg::do_write::cbs`,
`uvm_sequencer::item_done::t` and `uvm_sequencer_param_base::send_request::param_t`
reach `ref_var` by other laws entirely — and arm C's § 155 statement-typedef
local (`statementTd195::st_v195`) moves identically.

---

## 4. WHAT SHIPPED

`src/UhdmExporter.cpp`, one pass at the END of the `pkgCloneBodyLocals9` block —
**after** both § `pkgCloneHierBind9` / § `pkgCloneLocalRefBind37` sweeps, because
a law about what a listing does NOT carry can only be written once every binding
it omits exists. For each wildcard-import clone subroutine, a slot of its own
`Variables()` holding a `ref_var` with a non-null `vpiActual`:

* the object is **listed somewhere else** (the body block) → the SLOT takes an
  **unbound twin** (`*twin = *rv; twin->UhdmId(id); twin->Actual_group(nullptr);
  twin->VpiParent(tf)`) and the body keeps the bound object — golden's exact
  two-object shape;
* the object is **listed nowhere else** → it simply loses the binding, and
  nothing is minted. That is the TF-ITEM production of § 139: a paren-less
  function, or a task with a body io declaration, builds **no body `begin` at
  all** (arm A `tongs195`, `bellows195`).

The membership count is taken with the JUDGE'S OWN kind-agnostic accessor,
`GetByVpiType(vpiVariables)`, not a hand-written list of scope kinds. Golden's
subroutine-listing entry is parented at the SUBROUTINE (the body's at the body
block) and the twin transcribes that, though no generated `Compare` reads
`VpiParent` (RESUME §9).

Over the whole surelog corpus the two branches split **34 twin / 0 in-place** on
each moving row-mode; the in-place branch is exercised only by the grid
(`ct195pred` reports the branch per cell).

---

## 5. REFUTED: A VIEW CONJUNCT

Under `--elabuhdm` golden holds a clone subroutine's own listing **four** times
and splits it `{ACT=-:2, BOUND:2}` — un-elaborated copies bare, elaborated ones
bound. A first cut gated the omission on the DEF-view clone object
(`pkgDefMap[curPkgEmitSym] == pkgClassTfClone` for
`emitImportedPkgClassMethodClones`, `!pkgEmitTopView` for the free-subroutine
half). It was **wrong in both views**: `{ACT=-:1, BOUND:1}` in the plain view
where golden reads `{ACT=-:2}`, and `{ACT=-:1, BOUND:3}` under `--elabuhdm`.
That binary was built and measured (md5
`b9a1e2c09a6a5f12c67b8cc998ac2edb`) and is recorded here as refuted, not dressed
up. **Ungated**, both views land on golden's multiset exactly, for the reason
§ `connGenScope61` already records one law over: `uhdm_main.cpp` runs UHDM's OWN
`ElaboratorListener` under `--elabuhdm`, exactly as Surelog does, and that
listener re-binds the elaborated copy by name. The shipped code carries **no view
test at all**.

---

## 6. THE GRID (`grid195/`, `grid195.sh`, `score195.py`)

Every arm is compiled by ONE REAL SURELOG GOLDEN and BOTH binaries in BOTH views,
with every command AND ITS BINARY PATH echoed into `cmds.txt` and every rc
recorded (an `rc=139` segfault must never read as a result). Scoring is a
MULTISET join over `ct195cen`'s `LIST|` rows — `(scope kind, scope name, scope
span, owning package/class chain, slot index, var kind, var name)` keyed, with
the `vpiActual` as payload; the `PAR|` rows carry `vpiParent` and are DUMP-ONLY,
never scored, because no generated `Compare` reads it.

| arm | what it grids | def | elab |
|---|---|---|---|
| `g195_a_homes` | the head shape in 9 homes — out-of-body class task (ANSI) and function (paren-less), package free function with and without a paren header, package task with a body io decl, ANSI package task, a nested `begin`, a subroutine whose ONLY local is the process, one with no body statement — each in the HOME package and in the wildcard-import CLONE | **TO-GOLDEN 8 / AWAY 0 / MOVED-WRONG 0** | **8 / 0 / 0** |
| `g195_b_kinds` | 18 declared-type KINDS at the clone subroutine's own level: `process`, `semaphore`, `mailbox`, `event`, class handle, `string`, `int`, `bit`, `logic[3:0]`, `real`, packed struct, vector typedef, `chandle`, **`std::process`** (the scoped spelling), queue, dynamic array, associative array, fixed array | **4 / 0 / 0** — and **only** `process`, `semaphore`, `mailbox` move; every other kind AGREES on both binaries | **4 / 0 / 0** |
| `g195_c_shapes` | SCOPES (nested `begin`, NAMED begin, `fork` arm, `for`-body, `case` item — the NEGATIVES, since those listings are not the subroutine's own) and the OTHER `ref_var` producers (§ 155 statement typedef, § 166 name-based array typedef, two process locals in one subroutine) | **8 / 0 / 0** | **8 / 0 / 0** |
| `g195_d_control` | **THE CONTROL** — the same declarations with NO wildcard import, plus an EXPLICIT `import P::C`, plus a module `initial` body | **0 / 0 / 0, and the databases are BYTE-IDENTICAL** | **0 / 0 / 0, BYTE-IDENTICAL** |
| `g195_e_head` | **THE POSITIVE CONTROL** — the head, minimised to 20 lines | **29 cmp lines / 1 head → 0 / 0 `CMP_EQUAL`**; 1 / 0 / 0 | 1 / 0 / 0 |

Names are deliberately unalike across arms (`Quarry`/`Chisel`/`Sluice`/`Weir`/
`Gantry`/`Forge`/`Tongs`/`Bellows`/`Crucible`/`Anvil`/`Rivet`/`Press`/`Ladle`/
`Stile`/`Trestle`/`Loom`/`Bobbin`/`Hammer`), and arms A and C put the same
declaration in the HOME package and in the CLONE side by side so an arm that
AGREES is distinguishable from an arm that is not TESTING.

The residual `MOVED/STILL-WRONG` keys on arms A, B and C are **pre-existing and
identical on both binaries** (`MOVED-WRONG` is 0 on every arm and every view):
`press195`'s golden-only second slot, `statementTd195`'s begin-SPAN residue
(golden `@57:5-57:21`, ours `@58:5-58:20`), `arrayTd195`'s § 166 kind residue
(golden `ref_var`, ours `array_var`), and the elaborated `class_var l_h195`
listing residue. They are R1–R3 below.

---

## 7. THE A-PRIORI PREDICTION (over all 956 + 1358 databases)

`PREDICT.surelog.r10uvm195.txt` and `PREDICT.u2r.r10uvm195.txt` were written by
`predict195.sh` + `ct195pred` from the **PRISTINE** sweep workdirs alone, before
the patched sweep was read. The criterion is exactly what the emitter rewrites:
a slot of a `task_func`'s own `vpiVariables` holding a `ref_var` with a non-null
`vpiActual`.

```
surelog   scanned=948 NODB=617 FENCED=8
  ROW MiniAmiq,default    cells=34 twin=34 inplace=0
  ROW MiniAmiq,testflags  cells=34 twin=34 inplace=0
  ROW SeqDriver,default   cells=34 twin=34 inplace=0
  ROW SeqDriver,testflags cells=34 twin=34 inplace=0
uhdm2rtlil scanned=1358 NODB=104 FENCED=0
  (no row)
```

The patched sweep moved **exactly those four**, plus Scoreboard/default (the
coin). `MOVERS.r10uvm195.txt` lists the 17 clone subroutines by name and the
whole order-blind attribution.

---

## 8. RESIDUES AND R0

* **R0 — the NEXT HEAD, and it is a different object.** SeqDriver ×2 and
  MiniAmiq ×2 now read 198 cmp lines, one head:
  golden `unsupported_typespec: (m_verbosity_setting)@3393:5`, `vpiInstance ->
  package uvm_pkg`, under `ref_typespec
  (adpcm_pkg::uvm_component::m_set_cl_verb::setting)`; ours the resolved
  `struct_typespec: (m_verbosity_setting)@1686:11` parented at
  `class_defn uvm_pkg::uvm_component`. uvm-1.2
  `base/uvm_component.svh:3393` is `m_verbosity_setting setting;`, a
  subroutine-level local of the out-of-body `uvm_component::m_set_cl_verb`
  whose type is a typedef declared INSIDE the class (`:1686`). In the
  wildcard-import CLONE golden degrades it to an `unsupported_typespec` named
  for the written token and instanced at the HOME package — §
  `classScopedTdImportCopyUnsupported36`'s face on a CLONE BODY LOCAL. The pair
  is byte-identical in the pristine and the patched dump (`d.pris`/`d.pat`
  §112563), so it was already the second head and this pass did not create it.
* **R1** — golden gives `press195` (a subroutine whose only declaration is the
  process local and which has NO body statement) a SECOND `ref_var` slot at
  index 1 that we emit in neither package; grid arm A, both views, both the
  home and the clone. Untouched here.
* **R2** — a subroutine whose body is a lone statement-scope typedef declaration
  gets a body `begin` one line later in ours than in golden
  (`@58:5-58:20` vs `@57:5-57:21`); grid arm C, both packages, both views.
* **R3** — § 166's name-based ARRAY typedef local is a `ref_var` in golden's
  subroutine listing and an `array_var` in ours (grid arm C `arrayTd195`), and
  an elaborated in-body class method's `class_var` is listed at the `begin` in
  golden and at the `function` in ours (arm B/C elab, 2 keys). Both pre-existing
  in home and clone alike.

---

## 9. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm195repro
g++ -O2 -std=c++17 ct195cen.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct195cen
g++ -O2 -std=c++17 ct195own.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct195own
g++ -O2 -std=c++17 ct195list.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct195list
g++ -O2 -std=c++17 ct195pred.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct195pred

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid195/g195_*.sv; do CEN=/tmp/ct195cen bash grid195.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv); done
python3 score195.py /tmp/w_g195_e_head/cen.g.def.txt /tmp/w_g195_e_head/cen.a.def.txt /tmp/w_g195_e_head/cen.b.def.txt --show

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct195pred bash predict195.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the nine UVM row-modes
CEN=/tmp/ct195cen bash cen195.sh <pristine workdir> <patched workdir> /tmp/cen

# the wide boundary
PRIS=<PRISTINE> PATCHED=<PATCHED> bash bound195.sh <a COPY of tools/probe> /tmp/bnd

# the canary audit
bash canaudit.sh canaries.sh ctcan2.sh
```

`GATES.r10uvm195.txt` carries every gate verbatim; `DECODE.r10uvm195.txt` the
full decode; `HEADS.r10uvm195.txt` the before/after heads; `MOVERS.r10uvm195.txt`
the prediction and the order-blind attribution; `GRIDS.r10uvm195.txt` and
`CENSUS.r10uvm195.txt` the scored runs; `BOUNDARY.arms.r10uvm195.txt` the two
non-own boundary movers rebuilt against their own goldens.
