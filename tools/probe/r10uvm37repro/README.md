# r10uvm37 — UVM pass 37

Pass 36 closed the io_decl typespec family and handed over one number: **5910
binding keys, 3931 MISS / 1979 EXTRA**, with the misses 88% inside the
`adpcm_pkg` WILDCARD-IMPORT CLONE bodies and the extras dominated by implicit
function-return variables.  Both halves are decoded and both are down.

| metric | HEAD 570dfbb | this pass |
|---|---|---|
| `r10uvm28m.sh` `BINDTOTAL` | **5910** (1979 extra / 3931 miss) | **2311** (938 / 1373) — **-61%** |
| — BuildUVMPkg | 385 / 218 | 214 / 220 |
| — Scoreboard | 388 / 177 | 214 / 177 |
| — SeqDriver | 820 / 3171 | **298 / 611** |
| — SimpleUVM | 386 / 365 | 212 / 365 |
| `r10uvm31m.sh` `PAIRTOTAL` | 0 | **0** (held, 0/0/0/0) |
| `r10uvm30iom.sh` `IOTOTAL2` | 3 | **3** (held) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm27m.sh` CTORTOTAL / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL`.

Reproduce (probe: pass 28's `r10uvm28g`, unchanged; `r10uvm37lv` is new):

    g++ -std=c++20 -O2 tools/probe/r10uvm28g.cpp -o /tmp/r10uvm37_28g \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

    SL=$HOME/git-repos/Surelog/build/bin/surelog
    ( cd /tmp/a51 && $SL -parse -d uhdm -nobuiltin -noprecompiledcache \
        tools/probe/r10uvm37repro/t51b/dut.sv )
    /tmp/r10uvm37_28g /tmp/a51/slpp_all/surelog.uhdm

---

## 0. The arms

* **`t51a`** — a package `home51` with a FREE FUNCTION and a class, one
  wildcard importer `imp51`, one module importer.  Carries a foreach loop
  variable used as a bit_select index and as a plain rvalue, a body local, a
  body-local ARRAY, a formal, a nested block-local, and the NEGATIVES (a class
  property, `this`, and the implicit return variable).  The free function is
  what puts the clone in the importer's DEF *and* ELAB listings.
* **`t51b`** — the same questions inside an **out-of-body CLASS METHOD**,
  which is where 88% of the corpus residue lives.  Getting that clone to
  exist at all was the first thing this pass had to find: it is neither
  `extends` nor `-fileunit`.  **An out-of-body method is a PACKAGE item** (the
  home package's subroutine listing carries it), so it is what a wildcard
  importer clones; an INLINE method body is not in that listing and is never
  cloned.  `extern` + a definition outside the class body is the whole
  difference, and it is how UVM writes nearly every method.

## 1. § pkgCloneLocalRefBind37 + § pkgCloneLoopVarBind37 + § cloneForeachLoopVarUnresolved37 — the MISS side, -2560 keys

> Inside a wildcard-import CLONE body, EVERY unbound reference — `ref_obj`,
> `ref_var`, `bit_select` alike — whose name is one of the body's own locals,
> formals or FOREACH LOOP VARIABLES binds that object.  Pass 9 read the law
> off hier_path bases and method-call prefixes and wrote it only that widely.

`t51b`'s clone, golden vs ours before, with the home listing as the control
(both null there, in golden and in ours):

    DEFPKG imp52::c52::count | bit_select 'loc' -> array_var:loc   ours -
    DEFPKG imp52::c52::count | ref_var 'loc'    -> array_var:loc   ours -
    DEFPKG imp52::c52::count | ref_obj 'i' x2   -> ref_var:i       ours -
    DEFPKG imp52::c52::count | ref_var 'i'      -> ref_var:i       ours -
    ... and the same six rows again in the ELABPKG view

The **NEGATIVES cost nothing extra**: a CLASS PROPERTY reached bare
(`bit_select 'm_kids'`, and `ref_var 'm_kids'` as a foreach's array reference)
and `this` stay null in golden's clone, and they stay null here because
neither is in `pkgCloneBodyLocals9`.  That one restriction is the whole
predicate.

The LOOP VARIABLE needed two more facts, both read off `r10uvm37lv` (a new
probe: the same census keyed by serializer OBJECT ID, because `KIND:NAME`
cannot tell "binds the loop's own listing entry" from "binds a second object
of the same kind and name" — and that distinction is this whole section):

1. **The clone's loop variable is the UNRESOLVED `ref_var` in BOTH package
   views** (§ cloneForeachLoopVarUnresolved37).  `pkgDefViewBody9` already
   gave that to a class-method clone in either view and to a free function in
   the DEF view, but the importer's ELABORATED listing of a cloned FREE
   function fell through to the resolved arm and listed an `array_var`
   (t51a, `ELABPKG imp51::f51`).  A clone re-uses the home's UN-elaborated
   body whichever listing it lands in.
2. **The object every clone binds is a THIRD one** (§ cloneLoopVarShared37).
   Golden's ELABORATED home foreach lists `array_var i` in `vpiLoopVars` and
   keeps the unresolved `ref_var i` it started from — parented to the same
   foreach, out of the vector, `vpiActual` null — and both clone views bind
   THAT, the clone's own listing `ref_var i` included:

       ELABPKG home52::c52::count | foreach#1 lv=array_var:i#8
       ELABPKG home52::c52::count | ref ref_var:i#2 34:21 -> -      <- the orphan
       DEFPKG  imp52::c52::count  | foreach#7 lv=ref_var:i#14
       DEFPKG  imp52::c52::count  | ref ref_var:i#14 -> ref_var:i#2
       DEFPKG  imp52::c52::count  | ref ref_obj:i#64 -> ref_var:i#2
       BOTH    imp52::c52::count  | ref ref_var:i#10 -> ref_var:i#2   (same #2)

   We never build that intermediate — our elaborated loop variable is minted
   resolved from the start — so the shared object is minted at the one site
   that builds a clone's loop variable and keyed by the loop variable's
   DECLARATION SITE (`name@line:col`, § cloneStmtHomeVarRef17's key: the home
   body and every clone of it share that exactly).  KNOWN COSMETIC GAP: ours
   is parented to the FIRST clone's foreach where golden's hangs off the home
   elaborated one.  `uhdm-cmp` never reads a parent and the object is reached
   only through those bindings on both sides, but the r10uvm28g census does
   attribute it by parent, so the row shows up under `DEFPKG imp52::...`
   instead of `ELABPKG home52::...`.

Because the widened sweep now binds `ref_var` and `bit_select` too,
§ cloneStmtHomeVarRef17's "bind the ELABORATED HOME body's object, not the
clone's own listing entry" rewrite had to widen with it — golden's clone reads
`array_var:loc` with the HOME's object on the right.  The
§ cloneLoopVarShared37 object is deliberately untouched by that rewrite: it is
in no `Variables()` listing, so it is not in its map at all.

Measured on the corpus: `BINDTOTAL` 5910 -> 3350, SeqDriver misses
3171 -> 611, extras unchanged at 1979 (the required one-sided move).

## 2. § classRetNameDefViewNoBind37 — the EXTRA side, -1041 keys

> A CLASS METHOD's reference to its own IMPLICIT RETURN VARIABLE
> (`count = acc;` inside `function int c52::count`) binds ONLY in the
> ELABORATED listing of the method's class.  The home package's DEF-view
> listing and every wildcard-import CLONE leave it null.

`t51b` reads all four cells off one golden and `t51a`'s FREE function is the
control that keeps this from being written for every subroutine:

    ELABPKG home52::c52::count | ref_obj 'count' -> int_var:count   (bound)
    DEFPKG  home52::c52::count | ref_obj 'count' -> -
    DEFPKG  imp52::c52::count  | ref_obj 'count' -> -
    BOTH    imp52::c52::count  | ref_obj 'count' -> -
    CONTROL t51a: DEFPKG/BOTH home51::f51 'f51' -> int_var:f51, and the
      CLONE binds the clone's own unnamed return var — all three matched.

The corpus agrees cell for cell (all four tests, golden-bound/we-bind, `GO` =
agreed, `gO` = ours is an EXTRA):

    ELABPKG uvm_pkg   (home, elaborated)   343 GO    27 gO
    BOTH    uvm_pkg   (one shared object)  344 GO     4 gO
    DEFPKG  uvm_pkg   (home, def listing)    2 GO   693 gO
    DEFPKG  adpcm_pkg (clone, def)           0 GO   174 gO
    ELABPKG adpcm_pkg (clone, elab)          0 GO   174 gO

so the predicate is **the view that holds the CLASS, not the view that holds
the reference** — which is why this is applied DESIGN-FINAL and object-wise
(pass 36's lesson) rather than at `drainFuncRet`: whether a `class_defn` is
DEF-only or shared with a top package is not decidable while the def views are
still emitting.  The one shape the first cut got wrong was the home's own DEF
listing: an out-of-body method is a package item there too, so its `task_func`
has NO `class_defn` above it and the class test could not see it — the pass
falls back to the OWNING PACKAGE for exactly those, and a `class_defn` no
package lists at all (a module-scope class) is never touched.

Measured: `BINDTOTAL` 3350 -> 2311, extras 1979 -> 938, misses 1371 -> 1373
(the +2 are the two `DEFPKG uvm_pkg` `GO` rows the law flips, exactly as the
census predicted).

## 3. What is left, measured

SeqDriver's residue is now **298 extra / 611 miss** and it is a DIFFERENT
family — the clone bodies are no longer the story.  Ranked:

* **`this` bound to a `logic_net 'this'` in the HOME class views** — ~110 of
  SeqDriver's 611 misses, all `BOTH uvm_pkg::<class>::<method>`, spread over
  every statement context (`method_func_call/hier_path/assignment` 27,
  `assignment/begin/task` 19, `method_func_call/begin/function` 18, ...).
  Golden binds `this` to a `logic_net` named `this`; we leave it null.  One
  object kind, one name — this looks like a single law and it is the biggest
  single bucket left on both sides of the census.
* **`io_decl` in call arguments, both directions** — 54 MISS
  (`ELABPKG uvm_pkg::<cls>::uvm_report_*`, `method_func_call/function/
  class_defn`) against 79 EXTRA (`ELABPKG uvm_pkg`, `func_call/assignment/
  begin` 29 + `method_func_call/hier_path/operation#3` 28 +
  `method_func_call/hier_path/begin` 22).  A miss and an extra of the same
  kind in the same view is a POSITION rule we have drawn in the wrong place,
  not two laws.
* **`ref_obj -> io_decl` where the NAMES DISAGREE** — 26 rows
  (`DEFPKG adpcm_pkg::uvm_mem::get_rights | ref_obj 'this' ==> io_decl:map`).
  Golden binds a clone's `this` to the FORMAL that follows it; worth its own
  cell before it is folded into the `this` law above.
* **the last `ref_var` loop-variable stragglers** — 18 rows
  (`ref_obj 'rg_' / 'map_' / 'mem_'` under `uvm_reg_block`), a sub-shape
  § pkgCloneLoopVarBind37 does not reach; small, and the arm is already built.
* still open and untouched: the `IOTOTAL2`=3 POPULATION row (golden's unnamed
  io-less `task_func` under `ELABPKG uvm_pkg::uvm_reg_map` where we emit its
  local `ceil`), the MODULE arm of § classKeyTsScopeOwner35 (t47c), the socket
  sharing residue, `INITTOTAL`-52, t40a, `r10uvm23m` tf=2/var=34, t36b, t33d,
  hier_path root degradation.

## 4. Method notes

* **A `KIND:NAME` census cannot answer an IDENTITY question.**  `r10uvm28g`
  says the clone binds `ref_var:i` and that reads as "it binds its own listing
  entry"; `r10uvm37lv`, the same census keyed by object ID, says it binds a
  third object neither view lists.  Building the ID probe cost twenty minutes
  and was the difference between a law that measures and one that does not.
* **Find the TRIGGER before writing the arm.**  Two full arm cells produced no
  class-method clone at all, because the guess was `extends` and then
  `-fileunit`.  The answer was already in our own source
  (`emitImportedPkgClassMethodClones` iterates `collectPkgTfListing`, which
  only ever holds OUT-OF-BODY methods) and in pass 36's own t48c note.  Read
  the emitter for the trigger; use the arm for the law.
* **Measure BOTH sides before coding either.**  The handoff asked for it and
  it paid twice: the MISS fix had to leave the EXTRA count untouched to be
  believed (1979 -> 1979), and the EXTRA law's own +2 misses were predicted
  from the census before the build.
* **The def/elab predicate belongs to the DECLARATION, not the reference.**
  § classRetNameDefViewNoBind37 is the third law this campaign has had to move
  out of the emission site and into a design-final object pass for that
  reason.

## 5. Gate

* goldens **23 PASS**
* u2r testflags: **byte-identical** to `results/gate_uhdm2rtlil.csv` (732 lines)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv`
  (1589 lines) — zero status changes, `SLANG_REJECT` membership unchanged,
  none of the five pinned giants flaked
* byte verifier (the CSV is blind inside an already-NOTEQUAL row): the 11
  non-UVM `CMP_NOTEQUAL` tests, both modes, `slang.uhdm` compared against a
  pristine-HEAD binary, BOTH runs writing to the SAME workdir path
* `r10uvm28a` element head byte-identical pre/post on all four tests
