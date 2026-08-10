# r10uvm39 — UVM pass 39

Pass 38 handed over ONE ranked head: `method_func_call`-under-`hier_path`, the
position that was simultaneously the top of BINDTOTAL's misses, of BINDTOTAL's
extras and of 180 of SeqDriver's 755 BINDWRONG rows. It is decoded, and the
law it hides is a single sentence.

| metric | HEAD c0e6557 | this pass |
|---|---|---|
| `r10uvm28m.sh` `BINDTOTAL` | **1757** (938 extra / 819 miss) | **1677** (938 / **739**) |
| — BuildUVMPkg | 214 / 165 | 214 / 165 (untouched) |
| — Scoreboard | 214 / 122 | 214 / 122 (untouched) |
| — SeqDriver | 298 / 389 | 298 / **309** |
| — SimpleUVM | 212 / 143 | 212 / 143 (untouched) |
| `r10uvm38w.sh` `BINDWRONG` | 1010 (50/93/755/112) | **848** (50/93/**593**/112) |
| `r10uvm31m.sh` `PAIRTOTAL` | 0 | **0** (held) |
| `r10uvm30iom.sh` `IOTOTAL2` | 3 | **3** (held) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm27m.sh` CTOR / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL`. **The EXTRA half is
unchanged to the unit on all four tests** — the one-sided move a MISS-side law
must show.

New probe `tools/probe/r10uvm39h.cpp`; arms `t55a` and `t55b`. Reproduce:

    g++ -std=c++20 -O2 tools/probe/r10uvm39h.cpp -o /tmp/r10uvm39_h \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SL=$HOME/git-repos/Surelog/build/bin/surelog
    mkdir -p /tmp/a55b && cp tools/probe/r10uvm39repro/t55b/dut.sv /tmp/a55b/
    ( cd /tmp/a55b && $SL -parse -d uhdm -nobuiltin -noprecompiledcache dut.sv )
    /tmp/r10uvm39_h /tmp/a55b/slpp_all/surelog.uhdm | grep imp56

---

## 1. § hierCallArgTakesBase39 — the whole head, in one sentence

> A CLASS-METHOD call written `recv.m(args)` in EXPRESSION position, whose
> receiver is ONE bare name, gives **every DIRECT reference argument the
> RECEIVER's own `vpiActual`** — not the argument's own declaration, and not
> null.

    DEFPKG adpcm_pkg::uvm_component::create_component
      ref_obj 'factory'              -> class_var:factory   (the base)
      ref_obj 'requested_type_name'  -> class_var:factory   golden / io_decl ours
      ref_obj 'name'                 -> class_var:factory   golden / io_decl ours
      ref_obj 'this'                 -> class_var:factory   golden / <null> ours

Surelog's `compileTfCall` reaches the argument list through the dotted-name
path and resolves it against the object it has just bound the ROOT name to.
Nothing in the emitted tree records that, so it reads as a per-reference law and
**no KIND:NAME census can see it**: `r10uvm28m.sh` classifies each reference
bound-or-bare, and in 180 of these rows BOTH sides bind — to different objects.

### The projection that made it readable

`r10uvm39h` prints one line per reference that is an ARGUMENT of a
`method_func_call` inside a `hier_path`, carrying the BASE element's own actual
and a **pointer-identity** `SAME` flag (a body can hold two objects of one
name, so name equality would have lied). 4761 such rows across the UVM-4, and
`baseact` is very nearly the whole predicate:

| golden | SELF | BASE | BARE |
|---|---|---|---|
| base UNBOUND | 2166 | **0** | 2306 |
| base BOUND | 28 | **272** | 14 |

and adding the two shape gates leaves 4 exceptions in 270:

| gate (nelem, base kind, base bound) | SELF | BASE | BARE |
|---|---|---|---|
| `(2, ref_obj, yes)` | **4** | **266** | 0 |
| `(2, bit_select, yes)` | 6 | 0 | 0 |
| `(3, ref_obj, yes)` | 18 | 0 | 14 |
| `(4, ref_obj, yes)` | 0 | 6 | 0 |
| base unbound, any shape | 2166 | 0 | 2306 |

The `nelem=4` cell is a COINCIDENCE, not a BASE row —
`value.__m_uvm_status_container.cycle_check.exists(value)`'s argument is *named*
`value`, so `SAME` and `SELF` are both 1 for the same object. The 4 real
exceptions are `visited.exists(succ)`, §3.

Evaluated on OUR OWN rows the gate is an exact classifier: **all 262
disagreements sit inside it and no agreement does.**

    gate=1  G=BASE O=SELF   180      <- BINDWRONG, invisible to r10uvm28m
    gate=1  G=BASE O=BARE    82      <- BINDTOTAL miss
    gate=1  G=SELF O=SELF     4      <- the assoc-array exception, §3
    gate=0  ... 4471 rows, 438+20 residue, all of it a DIFFERENT law (§4)

## 2. t55a / t55b — every cell off ONE golden, negatives included

`t55a` proved the law exists and carried the two negatives the fix's gate must
not reach. `t55b` then put **all** shapes inside a clone body, because t55a's
deep / indexed / assoc / statement cells were class methods written INSIDE the
class — which an importer does not clone at all, so each was measured in the
home listing where the base is bare and the answer is vacuous. Every t55b cell
is a home-package FREE FUNCTION or an OUT-OF-BODY class method (the UVM shape),
so `imp56`'s two listings hold clones of all of them:

| cell | shape | base | golden arg |
|---|---|---|---|
| A `fFormal56` | `recv.take56(f, s)`, formal receiver | `io_decl:recv` | **BASE** |
| B `fLocal56` | body-local receiver | `class_var:loc` | **BASE** |
| I `fAssign56` | same call in an assignment RHS | `io_decl:recv9` | **BASE** |
| G `fOther56` | argument is a PACKAGE variable | `io_decl:recv7` | **BASE** |
| J `viaFormal56` | OUT-OF-BODY class method | `io_decl:recvA` | **BASE** |
| C `fDeep56` | `m3.deep.take56(...)`, length 3 | `io_decl:m3` **bound** | SELF |
| D `fIndex56` | `parr[i4].one56(f4)`, bit_select base | `array_var:parr` | SELF |
| E `fAssoc56` | `loc5.exists(k5)`, assoc built-in | `array_var:loc5` | SELF |
| F `fStmt56` | STATEMENT position | no hier_path at all | SELF |
| H `fNested56` | `recv8.take56(f8 + 1, s8)` | `io_decl:recv8` | `s8` BASE, **`f8` SELF** |
| K `viaProp56` | receiver is a CLASS PROPERTY | **unbound** | SELF |
| — `mm55` | class-method call from a MODULE body | **unbound** | SELF |

Cell C is the load-bearing one: the base IS bound and the arguments still keep
SELF, so the **length-2 gate is measured, not assumed**. Cell H fixes the fix's
reach: only the DIRECT arguments move, a reference one level down inside an
argument expression does not. Cell K and the module cell are why the gate needs
no view or scope test at all — see §5.

## 3. THE ONE CONDITION THE TREE CANNOT EXPRESS

`loc5.exists(k5)` (an ASSOCIATIVE-ARRAY BUILT-IN with a bound base) has the
**identical** two-element `hier_path{ref_obj, method_func_call}` shape and keeps
SELF. Golden's base there is an `array_var`, so "base's target is not an array"
looks like the predicate — and it is a TRAP: **our** emitter emits that same
declaration as a `logic_var` (§4's 91-row family), so the test would pass on
golden and silently fire on ours. The gate is therefore the ARM that built the
hier_path: `classRecvCallHp39` records the class-method arm's own hier_paths,
and a built-in method never enters it. Confirmed on t55b (cell E untouched) and
on the corpus (the 4 `visited.exists` rows are the only gate rows that did not
move).

## 4. What is left, MEASURED — and BINDWRONG is not what its name says

The head is closed: `BASE->BASE` 6 -> **248**, `BASE->SELF` 180 -> 18,
`BASE->BARE` 82 -> 2. Ranked residues, all measured this pass:

**(1) `BINDWRONG` 848 is 85% NOT A BINDING RESIDUE.** Splitting every row by
whether golden's and our target differ in NAME or only in KIND (single-object
keys only) re-ranks the whole metric:

| family | rows | tests | what it is |
|---|---|---|---|
| `Z-multiobj` | 342 | SeqDriver 328 | the census key holds 2+ objects on one side — an OWNER-ATTRIBUTION difference, not a binding one: golden's clone `foreach` loop-var ref is owned by a task_func whose fullname is `uvm_pkg::…` tagged BOTH, ours by `adpcm_pkg::…` tagged DEFPKG |
| `E-kindonly` (all) | 383 | all four | right NAME, wrong UHDM TYPE — a DECLARATION-emission law, still cmp-relevant (`uhdm-cmp` compares `VpiType`) |
| — `array_var` vs `logic_var` | **91** | 7/6/72/6 | a body-local ARRAY declared in a class method (`bit pred_of_succ[uvm_phase]`, `siblings[$]`, `provided_to_port_list`) comes out `logic_var`. **THE SAME BUG THAT MADE §3's GATE UNTESTABLE ON OUR SIDE** — fix it and the assoc exception becomes expressible |
| — `ref_var` vs `struct_var` | 76 | 4/4/64/4 | |
| — `ref_var` vs `class_var` | 72 | 10/6/50/6 | |
| — `bit_select` vs `string_var` | 48 | 12 each | |
| `D-bothdiff parameter/constant` | 82 | Scoreboard 41, SimpleUVM 41 | golden binds the `parameter`; we bind an unnamed FOLDED `constant` (package-level `param_assign` RHS: `UVM_LINE_WIDTH`, `UVM_MACRO_EXTRAS`) |
| `C-goldenOTHER` left | 20 | SeqDriver | the head's tail (see below) |

So **pass 40 should not read `BINDWRONG` as a binding metric.** Its head is a
declaration-KIND law and its second-largest bucket is an owner-attribution one.

**(2) `BARE -> SELF` 438 — the largest single-position EXTRA family, and it is
PER-ROUTINE.** In the same `method_func_call`-under-`hier_path` position with an
UNBOUND base, golden splits SELF/BARE and we over-bind 438 (BuildUVMPkg 111,
Scoreboard 111, SeqDriver 108, SimpleUVM 108); 427 of them sit in
`ELABPKG uvm_pkg`. Golden's choice is **homogeneous per owning task_func**:
354 owners all-SELF, 1082 all-BARE, only 26 mixed. Joining each reference
across the views gives the sharpest form of it:

    DEFPKG / ELABPKG / BOTH   golden        ours
      -    / BARE  /  -        1922          1517  (+422 we BIND)
      SELF / SELF  /  -         583           694
      SELF /  -    / SELF       456           474
      BASE / BASE  /  -         136             3   (this pass)
      BARE / BARE  /  -         131           171

i.e. **golden never binds this position in a routine the DEF listing does not
carry.** Two warnings for whoever takes it: (a) it is NOT a whole-body law —
those same ELABPKG-only routines still hold 7606 bound references elsewhere, so
it is position-scoped; (b) the method name is NOT the distinguisher (`exists`
alone is 153 SELF / 402 BARE inside `ELABPKG uvm_pkg`), and neither is
in-body-vs-out-of-body (`uvm_component::set_local` and
`uvm_component::define_domain` are both out-of-body and land on opposite sides).
The obvious mechanism to test first is a PARAMETERIZED-class specialization
(`uvm_callbacks#(T,CB)`, `uvm_config_db#(T)` are all-BARE) — but that model does
not cover `uvm_component::set_local`, so measure before modelling.

**(3) still open, measured not modelled** (carried from pass 38): the
`IOTOTAL2`=3 POPULATION row; the MODULE arm of § classKeyTsScopeOwner35; the
socket sharing residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=36; t36b; t33d;
hier_path root degradation. Pass 37's cosmetic loop-var parent gap is NOT
cmp-relevant — do not chase it as a law.

## 5. Why the fix needs no view test, and why it runs where it runs

`classRecvCallHp39` + "the base is BOUND" is the entire gate. The base of this
shape is bound in exactly ONE place — a wildcard-import CLONE body, by
§ pkgCloneHierBind9 — and the corpus agrees: **all 272 golden BASE rows are
`adpcm_pkg` (the clone), zero are `uvm_pkg` (the home)**, and both t55b's home
listing and t55a's MODULE body leave base and arguments alone on both sides. So
"base bound" IS the clone test, and no scope/view predicate had to be guessed.

Ordering: the pass runs **after § cloneStmtHomeVarRef17**, which re-points a
clone's body-local bindings. The base's FINAL actual is only knowable there, and
reading it earlier would propagate a stale target. It is the only writer of
these argument actuals and it OVERWRITES — 180 of the 262 rows were bound to the
wrong object, only 82 were null, so a fill-nulls-only pass would have won a
third of the family.

Determinism: iteration is over a pointer-keyed `std::set`, but every mutation
reads only its own hier_path's base and writes only that call's arguments, so no
two iterations interact and the output is order-independent. Two runs of the
final binary on SeqDriver are byte-identical.

## 6. Gate

* goldens **23 PASS** (with `SLANG_UHDM` pointed at this worktree's own binary —
  both `verify_golden.py:52` and `tests/check_goldens.sh:5` default to the
  MAIN-TREE binary and a false pass is indistinguishable from a real one)
* u2r testflags: **byte-identical** to `results/gate_uhdm2rtlil.csv` (732 lines,
  679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv`
  (1589 rows, whole row incl. DUMP) — 465/461 `CMP_EQUAL`, `SLANG_REJECT`
  membership unchanged, no pinned giant flaked
* byte verifier (the CSV is blind inside an already-`CMP_NOTEQUAL` row): every
  `slang.uhdm` the both-modes sweep emits, HEAD vs patched, **both runs writing
  to the SAME workdir path** — 953 databases, **951 identical / 2 differ**, and
  the two are `SeqDriver` in BOTH modes and nothing else. That is the law's own
  prediction: all 272 golden BASE rows are `adpcm_pkg` clones and SeqDriver is
  the only UVM-4 test with an importing package, so BuildUVMPkg, Scoreboard and
  SimpleUVM cannot change — a much sharper negative control than pass 38's
  7-of-953. The HEAD half of this run doubles as a BASELINE VALIDITY check: its
  own CSV is byte-identical to the committed `results/golden_surelog.csv`, so
  the committed baseline is reproducible on this machine.
* `r10uvm28a` element head byte-identical pre/post on all four; listing lengths
  unchanged (3672 / 3285 / 7959 / 3285)
