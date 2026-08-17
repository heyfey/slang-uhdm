# r10uvm87 — § `classTpTsResolvedNameEverySite87` — **THE `rsp_type` HEAD, CLOSED ON ALL SEVEN ROW-MODES**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **no corpus row
passes cmp**.

## The headline

r10uvm86 left ONE head standing on the five UVM rows (seven row-modes) — a
**class_typespec NAME**:

```
uvm_sequencer_param_base.svh:211:58     ( /* local */ extern function void m_last_req_push_front(REQ item); )
LHS golden  class_typespec (rsp_type)           span 211:58-211:61  parent class_defn uvm_sequencer_param_base
RHS ours    class_typespec (uvm_sequence_item)  NO span, NO parent
```

That head is gone. The **whole naming family** is gone with it: the census over
every `class_typespec` of `default/SeqDriver` goes from **12 owners whose name
set differs + 8 owners carrying an extra name** to **0 + 1**, and every one of
the **19** owner/defn pairs that moved lands **EXACTLY** on golden's name set.

| row-mode | cmp lines BEFORE → AFTER | head BEFORE → AFTER |
|---|---|---|
| SeqDriver / SimpleUVM / MiniAmiq (both modes), Scoreboard/default | 28 → **47** | `class_typespec(rsp_type)` vs `(uvm_sequence_item)` @**211:58** → `string_var uvm_pkg::s_connection_warning_id` **EXTRA-OURS** |
| BuildUVMPkg (both modes) | 17 → **17** | `ref_typespec uvm_pkg::uvm_is_match::s` — unchanged (its own older head) |

**The line count went UP and that is not a regression — it is the next rung
being printed** (`LADDERS.r10uvm87.txt`). The ladder proves it *from the PRISTINE database alone*: on
pristine `default/SeqDriver`, `ctladder` RUNG 1 is this pass's head
(`FAM=class_typespec|VpiName|TEXT:rsp_type|uvm_sequence_item`) and **RUNG 2, the
rung revealed by masking exactly that one object, is
`string_var(s_connection_warning_id) … SHAPE=EXTRA-OURS`** — the new head,
verbatim, present before any patch. Independently: the patched and pristine
`SeqDriver` databases differ in **152 dump lines and those lines are
`class_typespec` and `|vpiName` and NOTHING ELSE**, so no other divergence can
have been created.

## The law

> A class holds ONE `class_typespec` per DISTINCT RESOLVED CLASS among its own
> TYPE PARAMETERS. `§ classTypeParamTdGroupLastWins33c` named that object at the
> ONE site it owns — a task/function `io_decl` FORMAL. Golden wears the same
> name at **EVERY** site:
>
> * the class's own **`type_parameter`** typespecs,
> * a class **PROPERTY**,
> * the **ELEMENT** of a queue / dynamic / fixed / associative array property,
> * a method **BODY LOCAL** and a **NESTED-BLOCK** local,
> * a **RETURN** var,
>
> and the name is
>
> * the **LAST type parameter's typedef** (§ 33c's winner) when the group has
>   one; otherwise
> * the parameter's DEFAULT/OVERRIDE **spelling with any `#(...)` removed** —
>   or, when that spelling is itself a TYPE PARAMETER's name, the **RESOLVED
>   CLASS's own simple name**.
>
> The reach STOPS at the class body as WRITTEN: an **OUT-OF-BODY definition** is
> compiled in the home package's scope, where the class's type parameters are
> invisible, and every type written as one there degrades to an
> `unsupported_typespec` NAMED AS WRITTEN — its BODY LOCALS included.

### Why "rsp_type" and not "REQ" or "req_type"

`uvm_sequencer_param_base #(type REQ = uvm_sequence_item, type RSP = REQ)`
declares `typedef REQ req_type;` then `typedef RSP rsp_type;`. Both parameters
resolve to the SAME class, so they are ONE group; § 33c already measured (on
`t45a`, which REFUTED "the last typedef declared") that the winner is the typedef
of the **LAST PARAMETER in declaration order** that has one — `RSP` → `rsp_type`.
Arm `a1` re-reads that cell here from the opposite side: `c_swap` writes
`typedef RSP rsp_type;` **before** `typedef REQ req_type;` and golden still says
`rsp_type`.

The object's SPAN is the LAST use inside the class body (`211:58` in the corpus,
`15:24` in arm `a1`'s `c_uvm`), which is why a class whose only uses are written
as the TYPEDEF names keeps the class-header default's span instead (arm `a2`
`c_tduse`, `62:30`). Span and parent are the dump axis; the NAME is what
`class_typespec::Compare` reads, and the NAME is what this pass moves.

## The arms — every cell read off ONE golden, both directions

| arm | what it settles |
|---|---|
| `g87_a1_order.sv` | typedef ORDER (`c_swap`), typedef COUNT (`c_one`, `c_none`), which parameter the formal is written as (`c_rsp`), two parameters resolving to DIFFERENT classes (`c_two`), and the UVM shape verbatim (`c_uvm`) |
| `g87_a2_sites.sv` | WHICH DECLARATION SITES join the group: scalar / queue / dynamic / fixed / assoc property, method body local, nested-block local, return type, formal (`c_sites`, **12 holders, ONE golden object**); the no-typedef control (`c_notd`); non-class parameter defaults (`c_int`/`c_str`/`c_enum`, deliberate residue); the typedef-SPELLED use (`c_tduse`); a NON-parameterized class (`c_plain`); an OVERRIDDEN specialization (`c_spec`); an INHERITED parameter (`c_deri`) |
| `g87_a3_tpname.sv` | how a type parameter's own typespec is NAMED: simple / QUALIFIED / wildcard-imported spelling, `type B = A`, and two `#(...)` spellings |
| `g87_a4_sd9ctl.sv` | r10sd9's own committed NEGATIVE CONTROL (`g7_typeparam_control`), copied verbatim — it is the corpus head's shape and r10sd9 recorded that it "provably cannot move it" |

### the readings that fixed the law, and the two that refuted a first draft

* **`c_notd` (NO typedef anywhere) — the group STILL EXISTS and is still
  SHARED, and its name is the CLASS's** (`it87`, 5/5 holders). That is why site B
  fires ONLY when the group has a winning typedef: without that gate the law
  would have been a no-op there at best and a rename at worst. Golden and our
  PRISTINE build already agree on 4 of its 5 cells, and the 5th (the second
  type parameter, named `REQ` for its written text) is site A's.
* **`c_deri extends c_spec #(ot87)` writing `REQ p_scalar;`** — golden emits no
  typespec for it at all. The DECLARED-HERE test (`getParentScope() == body`) is
  what keeps this law off a shape it has not measured.
* **`t_qual`: `#(type A = q87::qbase)` → golden `q87::qbase`, NOT `qbase`.** The
  first draft of site A said "use the resolved class's name"; this cell refutes
  it. The written text is kept, `#(...)` and all-type-parameter spellings
  excepted.
* **`c_int` / `c_str` / `c_enum`** — golden groups an `int` / packed-struct /
  enum parameter the same way and names its `int_typespec` / `struct_typespec` /
  `enum_typespec` `rsp_type` / `p87b::rsp_type` too. **Left alone on purpose**:
  those are the shared PACKAGE-LISTING kinds `§ pkgImportAggCloneLastWriter32`
  and `§ tdListingFormalAsWritten33` own, and § 33c's own note records that
  binding them measured **+24 rows on BuildUVMPkg**. Residue **R1**, measured,
  not guessed.

## Where the code is

| site | file | what changed |
|---|---|---|
| helper | `src/TypeEmit.cpp` (`classTpGroup87`, `classTpGroupDeclName87`, `classTpTsName87`) | § 33c's winner table, rebuilt per class BODY scope and cached; the out-of-body fence; the name rules |
| **A** | `src/UhdmExporter.cpp` `emitClassParameters` | `cts->VpiName(rawText(dsyn))` → `classTpTsName87(...)` |
| **B** | `src/TypeEmit.cpp` `makeTypespec`, class-handle arm | the group name OVERRIDES both the class-name naming and § `localClassTsUnnamed15`'s suppression |
| **B** | `src/UhdmExporter.cpp` `classElemVar` | the ARRAY-ELEMENT mint — **this is the head** |
| **B** | `src/TaskFuncEmit.cpp` class-handle RETURN arm | the return typespec, **plus** the anonymity gate that decides "carries no vpiInstance" now also tests `tpGroupTs87` — naming the object without that would have silently ADDED a `vpiInstance`, which `Compare` reads |

`§ 33c`'s own code in `emitTaskFuncs` is **untouched**; the winner table is
transcribed rather than lifted out of it (it is a LOCAL of the listing pass and
these sites are not in that pass), and `MEMORY.md`'s "no premature extraction"
governs: the duplication is deliberate and the two walks are line-for-line the
same test.

## What did NOT move, and is recorded as residue

* **R1** — the `int` / `struct` / `enum` groups (above).
* **R2** — a property written as a type parameter in a group with **no** typedef
  keeps the RESOLVED class's simple name where golden keeps the parameter's
  written spelling **including its `pkg::` qualification** (arm `a3` `t_qual`
  `qbase` vs `q87::qbase`, `t_spec`/`t_selfspec` `qpar` vs `q87::qpar`).
  **Unchanged from pristine** — this pass neither fixes nor worsens it.
* **R3** — golden SHARES one object across all holders; we still mint one per
  declaration with the right name. Not cmp-judged (`Compare` reads the object,
  not the sharing). The census counts it: `SAME_NAMES_DIFF_COUNT` 29 → 36.
* **R4** — `uvm_callbacks`'s `typedef uvm_typed_callbacks#(T) super_type;` — a
  class typedef of a PARAMETERIZED CLASS, not of a type parameter. Different
  family (§ `classNestedClassTdGroupNoAnchor54`'s).
* **R5** — arm `a1` `c_swap`'s class **vpiTypedef LISTING** entry is still named
  `req_type` (the last TYPEDEF) where golden names it `rsp_type` (the group
  winner). That is the class-typedef listing law, not this one; pristine had the
  same name, so it is untouched.

## The ladder — the family counted, 6 → 0

`LADDERS.r10uvm87.txt`.  The pristine `default/SeqDriver` ladder runs to
**FIXPOINT: 425 rungs**, and `class_typespec|VpiName` fires **12** times.  Six of
them are this law (rungs **1, 69, 95, 170, 171, 172**); the other six are a
DIFFERENT law (a class handle bound to the wrong `class_defn` — golden
`adpcm_driver` where ours says `adpcm_sequencer` / `adpcm_test` /
`adpcm_tx_seq`) and are neither touched nor claimed.  The patched ladder was
**stopped by its time budget at 211 rungs** — a PARTIAL, said so — but 211 > 172,
so every index at which the pristine ladder fired this family has been passed,
and the only two `class_typespec|VpiName` rungs left in it are the OTHER family's.
**6 → 0.**  Only the ladder can see rungs 69/95/170/171/172; the official
uhdm-cmp stops at rung 1.

## The boundary, and one honest correction to the brief's own list

`v87bound.sh` compiles **555** committed arm sources — uvm77-86, buvm3-9,
sd8-12, **recursively**, because r10sd8..12 keep theirs in `grid6/`, `grid7/`,
`grid7v/` and a top-level `*.sv` glob would have reached nothing and read as
green — with BOTH binaries and compares dump bytes. **4 MOVED, 6 NO_OUTPUT.**

* the 6 `NO_OUTPUT` fail on **BOTH** binaries (checked file by file): multi-file
  arms that need sources this driver does not pass. Symmetric, pre-existing.
* the 4 movers are **ONE arm file duplicated across `r10sd9/10/11/12`**:
  `g7_typeparam_control.sv`, whose own header calls it "the pass's OWN
  REFUTATION CELL … this pass provably cannot move it" and names it as *"the
  corpus shape of `uvm_sequencer_param_base`'s `m_last_req_buffer`"*. It moves
  here, **toward golden**: its uhdm-cmp head changes from
  `class_typespec (t_type)` — this pass's exact family — to a different,
  pre-existing family (`pt::ct` vs `pt::ct #(pt::kt)`), and the count of objects
  correctly named `t_type` goes 2 → 6 against golden's 4.
* **`uvm82`'s "parameterized-class / type_parameter arms" did NOT move, and an
  arm that agrees is not an arm that tests.** `v82v_arm06_typeparam.sv` and
  `v82v_arm35_explicit_typeparam.sv` declare `parameter type T = int` at
  **PACKAGE** scope — not a class type parameter and not class-resolved — so
  this law cannot reach them by construction. The boundary that actually tests
  the uvm82 concern (a parameterized class reached across a package import) is
  arm `a3`'s `t_qual` / `t_imp` / `t_spec`, which are cross-package by design.

## Reproducing

```sh
# arms
PRI=<pristine> PAT=<patched> ./arm87.sh g87_a2_sites.sv
# census (golden vs ours), and the mover predictor on PRISTINE bytes only
g++ -O2 -std=c++17 ct87cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct87cen
./ct87cen <db.uhdm> --group      # one row per (owner class, target class)
./ct87cen <db.uhdm> --pred       # the site-A mover predictor
# gates
./sweep87.sh <binary> surelog pat ; ./ct8rows.sh <baseline.csv> <fresh.csv>
PRI=<pristine> PAT=<patched> ./v87bound.sh
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh <pat workdir> <pris workdir>
./canaudit.sh canaries.sh ctcan2.sh
```

`canaries.sh` and `canaudit.sh` gained **`MiniAmiq`** and **`Rggen`** in this
pass: the standing brief names both, `MiniAmiq` is one of the seven row-modes
this pass MOVES, and neither was carried by any driver — citing the canary gate
for them would have been this campaign's own "a cited guard that does not exist"
trap, committed on the pass's own rows. The surelog unknown-name expectation
stays 8; the u2r one rises 25 → 27, and the script's NOTE says so.


---

## VERIFIER RE-CUT (r10uvm87 adversarial verifier)

Every headline number above reproduced bit-for-bit from independent worktrees
and builds — both md5s, 9/955 movers (8 of the 9 md5 PAIRS identical; the 9th is
Scoreboard/default, the standing brief's ~50/50 coin, re-observed), the 28 -> 47
head move on six measurable row-modes, the 152-line `class_typespec`+`|vpiName`
SeqDriver delta, 555 boundary sources / 4 MOVED / 6 symmetric NO_OUTPUT, and
every canary pin.

**Three cells of `classTpGroup87`'s winner table were wrong and are fixed here**
(qualified typedefs are not candidates; a typedef-of-a-typedef consumes its
target; among one parameter's typedefs the FIRST wins). Two of the three were
`pristine-right -> patched-wrong` on legal SystemVerilog. Nine new arm sources
(`v87_a1..a9`) and the depth-keyed census that judged them are in this
directory; the full record, the ranked residues and the verdict are in
**`VERIFIER.r10uvm87.txt`**.
