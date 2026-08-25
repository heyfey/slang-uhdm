# r10uvm131 — § `parBlockJoinTailAfterFirstItem131`

**The head cleared:** MiniAmiq (both modes, 294 cmp lines, 1 head) —
`uvm_phase.svh:1400`'s `fork : master_phase_process … join_none`.
Golden's `named_fork` carries `vpiJoinType:1`; ours carried none.

```
LHS:                                                    RHS:
named_fork: (…master_phase_process), line:1400:9,       named_fork: (…master_phase_process), line:1400:16,
            endln:1413:18                                           endln:1400:36
|vpiName:master_phase_process                           |vpiName:master_phase_process
|vpiJoinType:1                                          (absent)
```

`named_fork::Compare` (UHDM `build/generated/src/named_fork.cpp:105`) reads
`VpiJoinType` right after the base compare and before `Stmts()`, so the whole
294-line MiniAmiq head is that one integer.  It also reads `VpiEndLabel`
(:111).  `VpiLineNo` is never read — the span half below is dump-only.

---

## 1. The decoded model (Surelog, `src/DesignCompile/CompileStmt.cpp`)

`compileStmt`'s **`paPar_block`** arm (`:380–508`) never looks at the join
keyword until it has walked **past the first item**:

* **join type** (`:456–507`).  The loop is

  ```c++
  while (item) {
    compileStmt(… item …);              // the first parallel statement
    item = fC->Sibling(item);           // :458
    if (item) {                         // … Join_keyword → VpiJoinType(…) … break
  ```

  An **empty** fork advances straight off the end of the child list, so the
  join keyword is never typed and `vpiJoinType` stays 0.  The two lines that
  stamp it (`:486-489`, `:494-497`, `:502-505`) treat `named_fork` and
  `fork_stmt` **identically** — `uhdmnamed_fork` gets the same
  `VpiJoinType(vpijointype)` as the unnamed one.  Only OUR emitter had split
  them.

* **end label** (`:397–409`).  The search opens at

  ```c++
  // Get join label if any
  NodeId tempItem = fC->Sibling(item);   // :398 — ONE NODE PAST the first item
  ```

  so an empty fork **steps over its own join keyword** and never records a
  `vpiEndLabel` either.

* **span** (`:1081`).  `paPar_block` makes **no** `populateCoreMembers` call
  of its own, so `compileStmt`'s tail fallback

  ```c++
  if (stmt->VpiLineNo() == 0) fC->populateCoreMembers(the_stmt, the_stmt, stmt);
  ```

  stamps the **whole `par_block` node** — `fork` keyword through the join
  keyword and its end label — on `named_fork` exactly as on `fork_stmt`.
  The `lbl : fork … join` form keeps that span too: the `slStringConst` arm's
  re-populate (`:924`/`:928`) does not reach a `named_fork`, so the start is
  the **`fork` TOKEN**, never the outer label.

**The seq_block arm differs on all three counts** (`:289–378`): `NodeId
tempItem = item;` (`:306`) starts *at* the item, there is no join keyword at
all, and `fC->populateCoreMembers(labelId, labelId, scope)` (`:336`) anchors a
`named_begin` at its **label token**.  So the gate below is **fork-only** and
an empty `begin : lbl end : lbl` keeps its label.

### The law

> **§ parBlockJoinTailAfterFirstItem131.**  A fork block's join tail
> (`vpiJoinType`, and `vpiEndLabel` on the named form) is reachable only when
> the par_block child list holds **at least one item** before the join
> keyword; a **syntax-visibly item-less** fork carries neither.  A
> `named_fork`'s span is the whole `fork … join` node — the `fork` token
> through the end label — not its label token; a `named_begin`'s span stays
> its label token.

Implemented in `src/StmtEmit.cpp` at the `StatementKind::Block` arm
(`joinTailSeen131` + the four sites that read it).  `bs.blockKind` supplies
the flavour; `bss131->items.empty()` is the par_block child list.

**Only a syntax-VISIBLE empty item list suppresses the tail.**  The first cut
of this pass wrote `bss131 && !bss131->items.empty()` — "no syntax ⇒ no tail",
which reads as the conservative choice and is wrong.  The wide boundary
convicted it: `task Hfrk(); fork bo.slot.put(tp.conv(kk)); join_none endtask`
(`tools/probe/r10v103repro/arms/v103_b2.sv:34`) reaches our emitter as a
**span-less, syntax-less** `fork_stmt` through the class-method body path, and
golden stamps it `vpiJoinType:1`.  A fork with no syntax is not evidence of
emptiness.  The shipped gate is `!bss131 || !bss131->items.empty()`.

---

## 2. Census — every fork in the nine UVM databases × both modes

`ct131cen.cpp` prints one row per `fork_stmt`/`named_fork` the `UhdmListener`
reaches, **deduped by `UhdmId`** (a NODEDUP census manufactures AWAY-GOLDEN
phantoms) and tagged with the first listing root that reached it.
`score131.py` joins golden/pristine/patched as a **multiset** on the
span-free, id-free key `KIND|NAME|ENDLBL|NSTMT|PATH`; `JOIN` and `SPAN` are
the scored columns.  Driver: `uvmcen131.sh` (golden path read from each row's
own `cmds.txt`; missing sides print SKIP-NOFILE and are counted; every rc
recorded).

Golden-vs-golden calibrates clean: **0 ONLY-GOLDEN, 0 ONLY-OURS, 0 AWAY** on
all nine databases — the key joins perfectly.

| row | mode | fork cells | named_fork | JOIN wrong (pris) | JOIN wrong (pat) |
|---|---|---|---|---|---|
| SeqDriver | default | 65 | 5 | 5 | 0 |
| SeqDriver | testflags | 65 | 5 | 5 | 0 |
| SimpleUVM | default | 38 | 3 | 3 | 0 |
| SimpleUVM | testflags | 38 | 3 | 3 | 0 |
| Scoreboard | default | 44 | 3 | 3 | 0 |
| MiniAmiq | default | 74 | 5 | 5 | 0 |
| MiniAmiq | testflags | 74 | 5 | 5 | 0 |
| BuildUVMPkg | default | 34 | 3 | 3 | 0 |
| BuildUVMPkg | testflags | 34 | 3 | 3 | 0 |
| **total** | | **466** | **35** | **35** | **0** |

The population is completely uniform:

* **431 `fork_stmt` cells** — 96 `join`, 234 `join_none`, 101 `join_any` —
  **already byte-right on both sides** (the unnamed arm always set the type).
* **35 `named_fork` cells** — every one of them golden `vpiJoinType:1`
  (`join_none`), ours 0.  26 carry no end label (`master_phase_process`),
  9 carry `vpiEndLabel:guard` (`uvm_objection::m_execute_scheduled_forks`),
  and our end labels already matched golden on all 9.
* **no fork anywhere in the corpus has zero statements**, so the empty-fork
  gate is corpus-invisible: it can only act on the boundary.

---

## 3. Mover prediction — BY NAME, from the pristine databases, a priori

`pred131.sh` walks every `slang.uhdm` in a verify_golden workdir and names the
databases that *can* move: those whose pristine dump holds a `named_fork` or a
zero-statement `fork_stmt`.  Every rc is recorded — a census that aborts is
printed as `CEN-FAIL` and counted, so a crash cannot read as "cannot move".

```
surelog  (956 scanned):  CAN-MOVE = 11, CEN-FAIL = 0
  default/   BuildUVMPkg  MiniAmiq  Scoreboard  SeqDriver  SimpleUVM  UnitElabBlock
  testflags/ BuildUVMPkg  MiniAmiq             SeqDriver  SimpleUVM  UnitElabBlock
uhdm2rtlil (1358 scanned): CAN-MOVE = 0,  CEN-FAIL = 0
```

`UnitElabBlock` is the eleventh mover and it is **CMP_EQUAL in the baseline**:
its `fork : innerwave … join` is a plain `join`, so `JOIN` is 0 on both sides
and stays 0 — only its **span** moves (`34:3-34:12` → `33:1-36:5`), which
`uhdm-cmp` never reads.  It moves bytes, not verdicts.

---

## 4. Grids and arms

`arms131.sh` compiles every `g131_*.sv` under Surelog, the pristine binary and
the patched binary in **both views**, and scores the fork cells.  Each arm is
copied into its own subdirectory keyed on its relative path; the file list is
read on fd 3, every child gets `</dev/null`, `PROCESSED` is asserted against
`LISTED`, and every rc is recorded.  Names, orders, case and numbers are varied
so an agreeing cell is not self-confirming.

| arm | what it varies |
|---|---|
| `g131_a_kinds.sv` | `join`/`join_any`/`join_none` × unnamed / `fork : lbl` / `lbl : fork` × end labels × multi-arm forks, module `initial` |
| `g131_b_homes.sv` | the same shapes in **five homes**: class task, class function, free package task, module `always`, module `initial`, `program` |
| `g131_c_nest.sv` | nested forks (named outside/inside and inverted), a fork whose body `disable`s its own label, **empty** forks of every flavour, a fork-local declaration, `disable fork` / `wait fork` |
| `g131_d_mult.sv` | **1–3 instances** of one fork-bearing module — the DEF view carries one copy, the ELAB view one per instance |
| `g131_e_endlbl.sv` | the end-label half, plus the **`named_begin` control** (`begin : emptyBeg end : emptyBeg`) that proves the quirk is fork-only |

Result (`JOIN` / `SPAN`, ten arm×view cells):

```
JOIN: WRONG->RIGHT 64   RIGHT->WRONG 0   WRONG->WRONG 0
SPAN: WRONG->RIGHT 93   RIGHT->WRONG 0   WRONG->WRONG 0
LISTED=5 PROCESSED=5   PROCESSED-ASSERT-OK
```

The three `AWAY`/`ONLY-OURS` pairs (`emptyNamed2`, `eF3`, `eF4`) are the
end-label fix itself: the pristine key carried `ENDLBL=eF3`, the patched key
is golden's `ENDLBL=-`, and the patched row matches golden on both scored
columns.  **MOVED-WRONG 0, AWAY-from-golden 0.**

Measured goldens the law reproduces (arm E, both views):

```
fork : eF1 join                      -> vpiJoinType 0, no vpiEndLabel
fork : eF2 join_any                  -> vpiJoinType 0, no vpiEndLabel
fork : eF3 join_none : eF3           -> vpiJoinType 0, no vpiEndLabel
fork : eF4 join : eF4                -> vpiJoinType 0, no vpiEndLabel
fork : fullFork z=4; join_none : fullFork -> vpiJoinType 1, vpiEndLabel fullFork
fork join_none  (empty, unnamed)     -> vpiJoinType 0
begin : emptyBeg end : emptyBeg      -> label SURVIVES (seq_block control)
```

`join : lbl` on an **unnamed** fork is slang-rejected ("trailing name not
allowed on previously unnamed block"), so Surelog's `named_fork`-with-an-
end-label-and-no-name shape is out of scope and is documented as such in the
arm rather than silently omitted.

---

## 5. Boundary

`bound131.sh` compiles a wide file set with **both** binaries in **both**
views, diffs the two workdir-normalised `uhdm-dump`s whole, and requires every
differing line to be one the law claims (`named_fork` / `fork_stmt` /
`vpiJoinType` / `vpiEndLabel`).  Subdirectory arms are compiled (a top-level
glob runs nothing and prints green), the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the **relative** path, `PROCESSED` is
asserted, rc mismatches are breaches, and `CTRL=1` runs a positive control
that proves the filter fires on an unclaimed line.

**A LINE FILTER IS NOT ENOUGH** — "the diff is fork-shaped" does not say the
fork moved *toward* golden, and the first cut of this pass passed the filter
while dropping a `vpiJoinType` golden carries.  So `GOLD=1` compiles every
MOVED cell under Surelog as well and scores it with `ct131cen`/`score131.py`;
the cell fails unless `RIGHT->WRONG` and `WRONG->WRONG` are 0 and no key of
ours is missing from golden on the patched side.  That is the check that
convicted the first cut, and it is now part of the gate.

The set: **314 files** (every probe `.sv`/`.svh` mentioning `fork`/`join`,
plus every third file carrying a named `begin` — the near-miss population that
must NOT move), each in both views.

---

## 6. Instruments

| file | what it is |
|---|---|
| `ct131cen.cpp` | the fork census (one row per fork, deduped by `UhdmId`, span- and id-free key) |
| `score131.py` | multiset golden/pristine/patched scorer for `JOIN` and `SPAN` |
| `uvmcen131.sh` | census driver over named rows of two verify_golden workdirs |
| `pred131.sh` | a-priori mover predictor over a whole workdir |
| `arms131.sh` + `g131_*.sv` | the grid |
| `bound131.sh` | the wide boundary gate |
| `canaudit.sh` `canaries.sh` `ctcan2.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the carried gates |

All of these are **measurement only**.  The official `uhdm-cmp` is the sole
acceptance judge.

---

## 7. Gates (all green, this pass's own frozen binaries, this pass's own workdirs)

| gate | result |
|---|---|
| build both, md5s | pristine `165b0bc396978d7f67d30949dc7b2ec2`, patched `ecc9954c33ac51609eb177cb9c02ef2b` (frozen `chmod 555` before every sweep) |
| goldens | 23 PASS / 0 FAIL on **each** binary, `SLANG_UHDM` exported explicitly; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (negative control) |
| u2r testflags + default | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, unchanged; `ct8rows` = 0 differing rows vs the committed baseline **and** vs this pass's pristine, in status **and** dump |
| u2r byteverify | `MOVERS 0 / 1358`, `PATH_SETS_IDENTICAL`, SELFCHECK 1357/1358 |
| surelog both modes | default 471 EQ / 10 NE, testflags 466 EQ / 9 NE — **identical histograms** to pristine; `ct8rows` = 0 differing rows over 1588 |
| surelog byteverify | `MOVERS 11 / 956` — **exactly the 11 `pred131.sh` named a priori**, `PATH_SETS_IDENTICAL`, SELFCHECK 955/956 |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS on both |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| fence audit | `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`; the four slang-fenced tests are never dispatched and appear nowhere in this directory outside `canaudit.sh`'s own list |
| boundary | 314 files × 2 views, `LISTED=314 PROCESSED=314 MOVED-CELLS=20 NO-DB=0 BREACH=0`, `PROCESSED-ASSERT-OK`, `POSITIVE-CONTROL-OK`, `BOUNDARY-PASS`; the 20 moved cells scored against golden: **204 fork cells, JOIN 84 WRONG→RIGHT, SPAN 115 WRONG→RIGHT, RIGHT→WRONG 0, WRONG→WRONG 0** |

No `results/*.csv` row was edited: this pass **converts no row**.  `Scoreboard/default`'s
patched hash differs between two patched runs — that row is the known ~50/50 coin;
it is a mover either way and was predicted by name.

`ctcan2` on the u2r side reports `unknown-patterns=6` and the canary drivers
report `unknown-names` (7 / 25) — those are the expected `EXPECT_UNKNOWN`
values carried by the standing battery, not new gaps.

### Heads before → after (`rowheads.sh`, DEPTH not distance)

```
                 pristine        patched
SeqDriver    def   17               17
SeqDriver    tf    17               17
SimpleUVM    def   64               64
SimpleUVM    tf    64               64
Scoreboard   def   64               64
MiniAmiq     def  294        ->     80     <- THE HEAD CLEARED
MiniAmiq     tf   294        ->     80
BuildUVMPkg  def   60               60
BuildUVMPkg  tf    60               60
Earlgrey_0_1 def   90               90
Earlgrey_0_1 tf   150              150
Rggen        def    0                0
```

`head_pris_*_MiniAmiq.cmp` and `head_pat_*_MiniAmiq.cmp` are the before/after
logs (both modes give byte-identical heads).

### R0 — the next head this pass exposes

MiniAmiq (both modes, 80 cmp lines, 1 head): `uvm_phase.svh:1730`
`foreach (m_successors[succ])`'s neighbour —
`get_predecessors_for_successors`'s `foreach_stmt` loop-variable slot.
Golden holds a `ref_var(successors)` carrying a `ref_typespec` → the
`array_typespec` declared at `1724:15`; ours holds a
`hier_path(successors[s].m_predecessors)` whose `vpiActual` is a
`bit_select(successors[s])`.  A `foreach` loop-variable / `Variables()` head,
not a fork head.

---

## 8. Residues this pass does NOT clear

* **`fork … join : lbl` on an unnamed fork** — Surelog builds a `named_fork`
  with a `vpiEndLabel` and **no** `vpiName`; slang rejects the source
  ("trailing name not allowed on previously unnamed block"), so the shape is
  unreachable for us and untested here.  Documented in `g131_e_endlbl.sv`.
* **span on a syntax-less fork** — the `v103_b2` class-method fork reaches us
  with no syntax and no source range at all; golden gives it none either
  (`fork_stmt: (Vb2::Hm2::Hfrk)` with no `line:`), so nothing moves, but the
  span law is only *measured* on syntax-bearing forks.
* **`fork_stmt::VpiName`** — Surelog's par_block `else` arm sets `labelId =
  the_stmt` and never names the unnamed fork; we match, but no arm probes a
  `lbl : fork` that lands on `fork_stmt`.
