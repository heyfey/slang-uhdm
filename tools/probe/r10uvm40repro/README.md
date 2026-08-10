# r10uvm40 — UVM pass 40

Pass 39 handed over a re-decomposed `BINDWRONG` and ranked its head first: 91
rows on ALL FOUR UVM-4 tests where golden's target is an `array_var` and ours a
`logic_var`. It is a DECLARATION-emission law, `uhdm-cmp` compares `VpiType`,
and it is decoded here in one sentence.

| metric | HEAD 1aeb0e0 | this pass |
|---|---|---|
| `r10uvm38w.sh` `BINDWRONG` | 848 (50/93/593/112) | **757** (43/87/**521**/106) |
| — `E-kindonly array_var vs logic_var` | **91** (7/6/72/6) | **0** (0/0/0/0) |
| `r10uvm28m.sh` `BINDTOTAL` | 1677 (938 extra / 739 miss) | **1681** (**938** / 743) |
| — BuildUVMPkg | 214 / 165 | 214 / 165 (untouched) |
| — Scoreboard | 214 / 122 | 214 / 122 (untouched) |
| — SeqDriver | 298 / 309 | 298 / 311 |
| — SimpleUVM | 212 / 143 | 212 / 145 |
| `r10uvm31m.sh` `PAIRTOTAL` | 0 | **0** (held) |
| `r10uvm30iom.sh` `IOTOTAL2` | 3 | **3** (held) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm27m.sh` CTOR / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |
| `r10uvm28a` listing residue | 3672/3285/7959/3285 | **3663/3276/7941/3276** |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL`. Every pre-metric was
re-measured on this box against the HEAD binary first and reproduced the
recorded baseline to the unit.

**`BINDTOTAL` went UP by 4 and that is NOT a model regression** — it is a
residue that only became VISIBLE. `r10uvm28m` classifies keys present on BOTH
sides, and before this pass we emitted no reference object at all in the
position; now we emit golden's object and leave its `vpiActual` null. The 4 are
one shape, fully decoded in §4(1), and the EXTRA half of `BINDTOTAL` is
unchanged to the unit on all four tests. The independent whole-census check
agrees the database moved toward golden: the `r10uvm40av` array-declaration
census diff on SimpleUVM goes **2475 -> 1834** lines, and `r10uvm28a`'s
listing residue drops on all four with its element head byte-identical.

New probe `tools/probe/r10uvm40av.cpp`; one arm, `t57a`. Reproduce:

    g++ -std=c++20 -O2 tools/probe/r10uvm40av.cpp -o /tmp/r10uvm40_av \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SL=$HOME/git-repos/Surelog/build/bin/surelog
    mkdir -p /tmp/a57a && cd /tmp/a57a
    $SL -parse -d uhdm -nobuiltin \
       <repo>/tools/probe/r10uvm40repro/t57a/dut.sv
    /tmp/r10uvm40_av /tmp/a57a/slpp_all/surelog.uhdm

---

## 1. § assocLocalArrayVar40 — the law

> A BODY-LOCAL **ASSOCIATIVE** array is an `array_var` with its ELEMENT
> variable under `vpiReg` and an `array_typespec` carrying one range per
> written dimension — exactly like the queue / dynamic / fixed forms we already
> emit. We were emitting the element type as a FLAT variable.

    DEFPKG uvm_pkg::uvm_phase::m_wait_for_pred
      ref_obj 'pred_of_succ'  -> array_var:pred_of_succ   golden
                              -> logic_var:pred_of_succ   ours

All 91 rows are one of eight declarations, and every one of them is a body local
of an OUT-OF-BODY class method: `bit pred_of_succ[uvm_phase]`,
`bit predecessors[uvm_phase]`, `bit successors[uvm_phase]`,
`bit siblings[uvm_phase]`, `int visited[uvm_phase]` (twice),
`uvm_port_component_base provided_to_port_list[string]`,
`uvm_factory_queue_class sorted_override_queues[string]`.

### The gate, and the two things t57a measured that a guess would have missed

`t57a` puts all five declaration forms and both negatives in ONE golden, each
one written THREE ways — out-of-body class method, in-body class method, and
package free function — plus a task, a nested `begin`, and a module subroutine.

**(a) REACH is the § blockItems9 BLOCK-ITEM production, nothing narrower.** The
negative is in the same golden: the paren-less `function void iNoParen57;`
keeps a flat ELEMENT variable (`int npa[key57]` -> `int_var`), so the arm sits
behind the same gate the queue arm already has. That cell also exposed a second
bug — our flat fall-through drilled Fixed/Queue/Dynamic but not Associative, so
it produced a `logic_var` carrying an `int_typespec`; it now drills the assoc
element too and gives golden's `int_var`.

**(b) The RANGE FORM follows Surelog's GRAMMAR, and the two spellings are
DIFFERENT MODELS** — the same split § assocIoRange9 decoded for an associative
FORMAL:

| index written as | production | array_typespec range | vpiIndexTypespec | vpiArrayType |
|---|---|---|---|---|
| a type KEYWORD (`[string]`, `[int]`) | paAssociative_dimension | `UINT:0 : STRING:associative`, index ts on the right constant | present | 3 |
| a NAME (`[uvm_phase]`, `[key57]`) | paConstant_expression = a SIZE | `UINT:0 : <name> - 1` (operation vpiSubOp over a ref_obj and `INT:1`) | **absent** | 1 |

**(c) ...and only the ELABORATED listing promotes the NAME spelling back to the
associative form.** This is the half a one-view arm would have got wrong in both
directions, and t57a measures all of it:

| cell | DEF listing | ELAB listing |
|---|---|---|
| `oob57::mAssocCls57::acls` (out-of-body method, tf-level) | SIZE | **ASSOC** |
| `oob57::tAssoc57::taq` (task, tf-level) | SIZE | **ASSOC** |
| `fAssocCls57::facls` (free function, tf-level) | SIZE | **ASSOC** |
| `fBlkAssoc57::bacls` (**nested `begin`**) | SIZE | SIZE |
| `inb57::iAssocCls57::iacls` (**in-body** class method) | — | SIZE |
| `work@top57.mmAssoc57::mmacls` (module subroutine) | SIZE | SIZE |

Surelog's ElaborationStep `array_var` pass reaches a package `task_func`'s own
`vpiVariables` and nothing deeper — which is why a NESTED-`begin` local and an
in-body class method's local stay size-model in every view. **The real corpus
confirms the nested-`begin` half independently**: `uvm_phase::sync` and
`::unsync` declare `int visited[uvm_phase]` inside an `else if (...) begin`
block, and golden leaves BOTH of their views size-model (`atype=1`, range =
operation) while `m_wait_for_pred`'s tf-level `pred_of_succ` — the same
`[uvm_phase]` spelling — is promoted. Had the law been "the elaborated listing
always promotes", those four array_vars would have been wrong.

**(d) `promoteNamed` is spelled per LISTING, not per view flag**, because the
three listings that can carry a package `task_func` are built at three
different times: an out-of-body definition's own listing comes from
`emitPackageClasses` (top view, promoted) and its DEF twin from
`emitPackageClassMethodClones` (`cloneMode`, not promoted); a free function is
emitted once per view under `pkgTopEmit`; an in-body class method is never
promoted. Hence `oob ? !cloneMode : (pkgTopEmit && !classScope)`.

**(e) the ELEMENT and INDEX typespecs carry the same `vpiInstance` the flat
local already took** — the home package for a free function or an out-of-body
method, nothing for an in-body one, i.e. exactly `tsInst`. `uhdm-cmp` RECURSES
a typespec's `Instance()`, so this is a compared field and the flat path we
replaced was already getting it right; a helper modelled on
`makeQueueDynArrayVar` alone would have LOST it.

## 2. § queueLocalElemTsInstance40 — the unmeasured half of an old NOTE

Building t57a's census with `Instance()` in the projection exposed a
PRE-EXISTING gap in the neighbouring arm. `makeQueueDynArrayVar` carried

    // NOTE: no vpiInstance on the element ts — Surelog leaves a class-method
    // local's typespec unscoped (measured).

and that note had only ever seen the IN-BODY spelling, where `tsInst` is null
anyway. t57a measures both halves in one golden: `oob57::mQueue57`/`mDyn57` are
`int_typespec@pk57` and `inb57::iQueue57` is unscoped. The helper now takes the
same `tsInst` the FIXED arm and the flat local already use. (A LAW THAT ONLY
EVER SAW ONE SPELLING HAS AN UNMEASURED HALF — this one had.)

## 3. § the assoc INDEX typespec keeps its SIGN

`predefIntTypespec` deliberately drops `vpiSigned` (the io_decl / local copy
Surelog hands back is the unsigned-looking one, `PreprocFunc`), but the INDEX
typespec of an `[int]` dimension carries it — t57a `mAssocInt57::aint`, the last
cmp difference left inside the arm. Set only on the freshly-minted
predefined-integer arm; a typedef index resolves to a SHARED object that must
not be mutated. Zero reach on the UVM-4 (which spell `[string]` and
`[uvm_phase]`) — it is here so the arm is cmp-clean and the next pass can trust
it.

## 4. What is left, MEASURED

**(1) THE MODULE-IMPLICIT-NET ARM — fully decoded, not implemented, and it owns
the whole +4.** Surelog creates ONE implicit `logic_net` per index NAME, named
after the identifier, parented to the **DEF-view** (`uhdmallModules`)
`module_inst`, spanned at the FIRST such occurrence in the design, and shared —
`work@top.uvm_phase` @1664:21 is the only one in the whole SimpleUVM golden
(t57a's module cell is the same net, and it is the only remaining `uhdm-cmp`
difference in that arm). The binding rule is the sharp part, and
`r10uvm40av`'s operand projection names it:

    BOTH   uvm_pkg::uvm_phase::sync   ... [0 : operation ref'uvm_phase'->logic_net:uvm_phase]
    DEFPKG uvm_pkg::uvm_phase::sync   ... [0 : operation ref'uvm_phase'-><null>]

i.e. **the ELABORATED listing's size-model index reference binds the net; the
DEF listing's stays null.** Do not shortcut this: `r10uvm28m` keys on a SET of
actuals, so binding BOTH views would clear the 4 misses *and* create 4 fresh
`Z-multiobj` `BINDWRONG` rows — a wash dressed as a win. Reach: 4 census rows
(SeqDriver + SimpleUVM, `visited` @1896:17 and @1946:17 — the two nested-`begin`
locals, the only size-model survivors of the promotion). Cost: an `elabListing`
flag (the same `oob ? !cloneMode : pkgTopEmit`, WITHOUT `!classScope`, and it
must be visible from StmtEmit because the declaration is a block local), a
recorded `{ref_obj, name, span}` list, and a design-final pass that picks the
span by a TOTAL ORDER on (file,line,col) — never first-hit. Unmeasured: which
module gets the net when a design has more than one top module.

**(2) the rest of `BINDWRONG`'s 757, re-ranked after this pass:**

| family | rows | tests | note |
|---|---|---|---|
| `Z-multiobj` | 342 | SeqDriver 328 | pass 39's OWNER-ATTRIBUTION shape, untouched |
| `ref_var` vs `struct_var` | 76 | 4/4/64/4 | now the head of the declaration-KIND class |
| `ref_var` vs `class_var` | 72 | 10/6/50/6 | |
| `bit_select` vs `string_var` | 48 | 12 each | |
| `D-bothdiff parameter/constant` | 82 | Scoreboard 41, SimpleUVM 41 | golden binds the `parameter`, we bind a folded `constant` |
| `parameter/operation` | 20 | Scoreboard 10, SimpleUVM 10 | |
| `string_var/int_var` | 18 | SeqDriver | |
| `logic_net` vs `class_var` | 20 | SeqDriver 10, SimpleUVM 10 | |
| `operation` vs `constant` | 15 | | |
| the long tail | ~64 | | |

The whole `array_var vs logic_var` row is gone from every test.

**(3) still open, measured not modelled** (carried): `BARE -> SELF` 438 (pass
39 §4(2) — homogeneous PER ROUTINE, find the routine property first); the
`IOTOTAL2`=3 POPULATION row; the MODULE arm of § classKeyTsScopeOwner35; the
socket sharing residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=36; t36b; t33d.
Pass 37's cosmetic loop-var parent gap is NOT cmp-relevant.

## 5. Determinism

Nothing here iterates a pointer-keyed container: `makeAssocArrayVar` is called
once per declaration on the ordinary emission walk, reads only that
declarator's own syntax, and writes only its own objects. Two runs of the final
binary on SeqDriver are byte-identical (`md5 ebf7eb23…`).

## 6. Gate

* goldens **23 PASS** (with `SLANG_UHDM` pointed at this worktree's own binary)
* u2r testflags: **byte-identical** to `results/gate_uhdm2rtlil.csv` (732 lines,
  679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv` (1589
  rows, whole row incl. DUMP) — 465/461 `CMP_EQUAL`, `SLANG_REJECT` membership
  unchanged, no pinned giant flaked
* byte verifier (the CSV is blind inside an already-`CMP_NOTEQUAL` row): every
  `slang.uhdm` the both-modes sweep emits, HEAD vs patched, **both runs writing
  to the SAME workdir path** — 953 databases, **946 identical / 7 differ**, and
  the 7 are EXACTLY the 7 comparable UVM-4 rows (BuildUVMPkg, Scoreboard,
  SeqDriver, SimpleUVM `default` + BuildUVMPkg, SeqDriver, SimpleUVM
  `testflags`; Scoreboard's `testflags` row is `SLANG_REJECT`). Nothing else in
  either corpus moved a byte — which is the sharp negative control this law
  needs, since a declaration-emission law COULD have moved the DUMP column
  anywhere.
* the HEAD half of that run doubles as a BASELINE VALIDITY check: its own CSV is
  byte-identical to the committed `results/golden_surelog.csv`, so the committed
  baseline is reproducible on this machine.
* `r10uvm28a` element head byte-identical pre/post on all four; listing residue
  3672/3285/7959/3285 -> 3663/3276/7941/3276.
