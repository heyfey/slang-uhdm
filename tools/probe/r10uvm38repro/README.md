# r10uvm38 — UVM pass 38

Pass 37 handed over **2311 binding keys, 1373 MISS / 938 EXTRA**, with the
`this` bucket ranked first and the `io_decl`-in-call-arguments family second.
Both are decoded; the MISS half is down 40% and the EXTRA half is untouched
(the required one-sided move for two MISS-side laws).

| metric | HEAD 3d60fa2 | this pass |
|---|---|---|
| `r10uvm28m.sh` `BINDTOTAL` | **2311** (938 extra / 1373 miss) | **1757** (938 / 819) — **-24%** |
| — BuildUVMPkg | 214 / 220 | 214 / **165** |
| — Scoreboard | 214 / 177 | 214 / **122** |
| — SeqDriver | 298 / 611 | 298 / **389** |
| — SimpleUVM | 212 / 365 | 212 / **143** |
| `r10uvm38w.sh` `BINDWRONG` (NEW) | 1010 | 1010 (held; see §3) |
| `r10uvm31m.sh` `PAIRTOTAL` | 0 | **0** (held) |
| `r10uvm30iom.sh` `IOTOTAL2` | 3 | **3** (held) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL`.

Reproduce (probes: pass 28's `r10uvm28g` unchanged; `r10uvm38t` and
`r10uvm38n` are new):

    g++ -std=c++20 -O2 tools/probe/r10uvm28g.cpp -o /tmp/r10uvm38_28g \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SL=$HOME/git-repos/Surelog/build/bin/surelog
    ( cd /tmp/a54 && $SL -parse -d uhdm -nobuiltin -noprecompiledcache \
        tools/probe/r10uvm38repro/t54a/dut.sv )
    /tmp/r10uvm38_28g /tmp/a54/slpp_all/surelog.uhdm

---

## 1. § thisImplicitNetBoth38 — the `this` bucket, -334 keys

> A bare `this` inside a class method that a MODULE listing carries binds ONE
> implicit `logic_net` named `this`, minted in the DEF-VIEW listing of the top
> module.  A `this` that is a hier_path PATH ELEMENT (`this.m_kids`) is never
> bound, in any listing.

`r10uvm38t` (new: every object named `this`, with parents, net type and a
binder count) answers the question a KIND:NAME census cannot — golden SeqDriver
holds **exactly one** such object and 177 references share it:

    logic_net#75 full='work@top_tb.this' netType=1 ts=n loc=902:36
      binders=177 parents=module_inst:#1 < design:work@top_tb#1

so this is the § implicitNetMap mechanism (the wire Surelog's module-level late
binding mints for a name it cannot resolve — a block localparam, a foreach loop
variable, a task-scope parameter) applied to `this`: an out-of-body method body
is compiled in the home PACKAGE's scope, where the class's own implicit `this`
property is invisible, and a module-scope wildcard import materializes those
same `task_func` objects into the MODULE, whose late binding mints module nets.

The 2x2, over the r10uvm28g census of all four tests, predicate evaluated on
OUR OWN rows and truth = what golden binds:

    BOTH   + parent is NOT a hier_path   177 bound, ALL to logic_net:this
    BOTH   + parent IS a hier_path       285 bare, 0 bound
    DEFPKG + parent is NOT a hier_path    28 bound (the § io_decl:map family
                                          below), 326 bare, none to a net
    ELABPKG same shape                    28 bound, 383 bare, same
    DEFPKG/ELABPKG + parent IS hier_path 875 bare, 0 bound

BuildUVMPkg and Scoreboard are the negative controls: no task_func of theirs is
module-listed, and neither golden holds a `logic_net` named `this` at all — so
the law is a no-op on them, and the byte verifier confirms it (only SeqDriver
and SimpleUVM databases change).

**THE LABEL IS NOT WHAT IT LOOKS LIKE.** `r10uvm28g`'s "BOTH" reads as "both
package views", and written that way the law measured a flat **ZERO** on the
corpus: `AllPackages` and `TopPackages` share **no** task_func object at all
(1788 / 4822, intersection 0).  `tagScope` merges to `BOTH` on any two
DIFFERENT tags, and for every one of the 195 candidates the pair is a TOP
PACKAGE plus BOTH MODULE listings (894 module-listed routines, def and top
sharing the object).  Three `fprintf` counters found that in one run; no amount
of arm-cell work would have, because the arm reproduces a law, not a label.

## 2. § thisRecvCallArgBind38 — the call-argument half, -220 keys

> A STATEMENT-position **direct** `this.m(f)` binds its arguments like any
> other call.  The EXPRESSION form and every **deep** `this.<member>.m(f)`
> leave them bare.

The § thisRecvCall11 arm never opened a `ClassArgBind12` window, so `this.`-
rooted call arguments stayed null where every other call form binds them: 54
rows of SeqDriver, all of them an INLINE class method whose whole body is one
such call (`uvm_sequence_item` / `uvm_report_catcher`'s `uvm_report_*`
wrappers).  `t54a` reads all five cells off ONE golden and ours now matches all
twelve of its census rows byte for byte:

    this.inner54(y, t);            STATEMENT   -> io_decl:y / io_decl:t
    return this.inner55(y3);       EXPRESSION  -> BARE (both sides)
    this.nested.deep54(y4, t4);    DEEP stmt   -> BARE (both sides)
    inner54(y2, t2);               control     -> bound (both sides)
    super.new(nm2);                control     -> bound (both sides)

**THE DEEP HALF WAS THE UNMEASURED ONE AND IT COST MORE THAN THE LAW WON.**
Run on the corpus with the statement gate alone: 55 misses removed, **95 extras
added** — BINDTOTAL 1977 -> 2137, worse than not doing it.  Every added extra
was a deep call: UVM's TLM forwarding macros
(`UVM_BLOCKING_GET_IMP(this.m_if, T, t)` expanding to `imp.get(arg)`) and
`uvm_report_catcher`'s `this.m_modified_report_message.set_id(id)`.  The first
reading of those extras was a FUNCTION-vs-TASK split (62 of 95 sat under
`method_func_call/task/class_defn`) and it was a coincidence of which routines
happen to be written deep — reading the SOURCE of two extras, not their census
context, is what separated the two.

## 3. `BINDWRONG` — a residue `r10uvm28m.sh` cannot see (NEW, 1010)

`r10uvm28m.sh` classifies each reference as bound-or-bare and counts the
disagreements.  A reference **both** sides bind, to **different** declarations,
is invisible to it — and `uhdm-cmp` descends `Actual_group` and compares the
target's `VpiName`, so those are real differences.  `r10uvm38w.sh` counts them:

    BuildUVMPkg 50   Scoreboard 93   SeqDriver 755   SimpleUVM 112   = 1010

unchanged by both laws here (both only ever fill a null).  180 of SeqDriver's
755 are one family, and it is the same POSITION family as the ranked
`io_decl`-in-arguments item: in a CLONE body a reference in
`method_func_call`-under-`hier_path` position binds the **hier_path BASE's**
object, where we bind the argument's own name —

    child_map.get_n_bytes(UVM_NO_HIER)      G: UVM_NO_HIER -> io_decl:child_map
    map.get_reg_map_info(this)              G: this        -> io_decl:map
    sequence_ptr.m_get_sqr_sequence_id(m_sequencer_id, 1)
                                            G: m_sequencer_id -> io_decl:
                                                                 sequence_ptr

## 4. What is left, measured (SeqDriver, 298 extra / 389 miss / 755 wrong)

The `method_func_call/hier_path` family is now the whole head, on all three
metrics at once, and it is ONE question asked in four views:

| cell | count | golden | ours |
|---|---|---|---|
| ELABPKG uvm_pkg (home elab) | 394 | bare | bare |
| ELABPKG uvm_pkg | **105** | **bare** | **binds SELF** (EXTRA) |
| DEFPKG uvm_pkg (home def) | 224 | SELF | SELF |
| BOTH uvm_pkg | 272 | SELF | SELF |
| adpcm_pkg clone, both views | 268 | SELF | SELF |
| adpcm_pkg clone, both views | **180** | **BASE's object** | SELF (WRONG) |
| adpcm_pkg clone, both views | **82** | **BASE's object** | bare (MISS) |

**Do not read this as a view law** — that was tried and it is refuted: in
BuildUVMPkg and Scoreboard the SAME view+package cell (`ELABPKG uvm_pkg`) holds
220/226 agreed-SELF rows *and* 374/449 agreed-bare rows *and* the 105 extras.
The distinguisher is per-REFERENCE and the arm has to find it; the strongest
hypothesis from the sources above is *whether the reference's own name is one of
the body's own formals/locals* (a class property, an enum constant and `this`
all take the BASE's object instead).

Also open, measured not modelled: `MISS method_func_call/begin ELABPKG` 36;
`EXTRA func_call/assignment ELABPKG` 31; `MISS operation#15/begin ELABPKG` 23;
`EXTRA hier_path/assignment BOTH` 18 (a `logic_net` we mint for a class
property where golden binds nothing); `MISS assignment/begin` 25; the
`IOTOTAL2`=3 POPULATION row; the MODULE arm of § classKeyTsScopeOwner35; the
socket sharing residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=36; t36b; t33d;
hier_path root degradation.

## 5. Gate

* goldens **23 PASS**
* u2r testflags: **byte-identical** to `results/gate_uhdm2rtlil.csv` (732 lines)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv`
  (1589 lines, whole row incl. DUMP) — zero status changes, 465/461
  `CMP_EQUAL`, `SLANG_REJECT` membership unchanged, no pinned giant flaked
* byte verifier (the CSV is blind inside an already-`CMP_NOTEQUAL` row): EVERY
  `slang.uhdm` the both-modes sweep emits, HEAD vs patched, BOTH runs writing to
  the SAME workdir path — 953 databases, **946 identical / 7 differ**, and the 7
  are exactly the UVM-4 comparable rows (`BuildUVMPkg`, `SeqDriver`, `SimpleUVM`
  both modes + `Scoreboard` default; Scoreboard's testflags row is
  `SLANG_REJECT` and emits no database).  Staged: after **law A alone** exactly
  **4** differed — SeqDriver and SimpleUVM only — which is law A's own
  prediction from its negative controls (BuildUVMPkg and Scoreboard have no
  module-listed routine, so law A cannot fire there).
* `r10uvm28a` element head byte-identical pre/post on all four, and its listing
  length unchanged (3672 / 3285 / 7959 / 3285)
* determinism: two runs of the final binary on SeqDriver are byte-identical
  (`Serializer::AllObjects` is pointer-keyed, so the minted net's span is picked
  by a total order on the SOURCE, not by "the first hit")
