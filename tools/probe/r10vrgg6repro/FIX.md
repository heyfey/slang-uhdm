# r10vrgg6 — THE ONE PRODUCTION CHANGE THE VERIFIER ADDED

## The defect: § nestedParamActualTs6 could mint a ref_typespec in the DEF LISTING

`paramRhsObj` is keyed by the parameter's **body symbol**, and BOTH views write
it — the codebase already records this hazard in `ParamEmit.cpp` beside the
`elabOvMisevalRhs` map ("Recorded separately from paramRhsObj because that map
is keyed by the SAME body symbols the def-view pass overwrites").  So the map
holds whichever view ran LAST.

The write-through law reads it at an arbitrary emission point.  When the DRIVING
site is reached BEFORE the enclosing instance's ELAB `param_assign`s, the map
still holds the **DEF-view** Rhs, and the law stamps THAT — putting a
`ref_typespec` in the definition listing where golden has none.  That is the
exact spurious-object class this pass exists to remove from Rggen.

MEASURED, `cells/w_port_conn` (`sub u_s (.i(32'(f3(P2))))`), all three binaries
against real Surelog:

    gold      DEF P1 none   DEF P2 none   ELAB P1 ts@17:41   ELAB P2 ts@23:29
    base      DEF P1 none   DEF P2 none   ELAB P1 ts@17:41   ELAB P2 none
    r10rgg6   DEF P1 TS!!   DEF P2 none   ELAB P1 none       ELAB P2 none
    r10vrgg6  DEF P1 none   DEF P2 none   ELAB P1 none       ELAB P2 none

`R10RGG6_TRACE=1` plus a temporary print of every negative flag shows the fire
happens with `moduleDefEmit=0 paramInitDef=0 paramInitPkg=0 inProcessEmit=0
inGenScopeProc=0 defGenProcessEmit=0 ndaRhsEmit=0 elabConnEmit21=0
portInitCtx=0 contAssignView=0 inLhs=0` — every existing negative clause is
CLEAR.  No flag can express this; the map itself has to carry the view.

## The fix (pure NARROWING — it can only ever REMOVE a stamp)

`src/ParamEmit.cpp` records the Rhs a SECOND time, on the PHYSICAL elaborated
view only (`topView && !defViewOrig9` — `defViewOrig9` and not `topView`,
because § modDefImportShape force-flips `topView` while emitting a materialized
import copy's DEF listing), into a new `elabParamRhsObj6`.
`stampNestedParamActualTs6` then stamps only when `paramRhsObj[psym]` and
`elabParamRhsObj6[psym]` are THE SAME OBJECT.

    +  if (topView && !defViewOrig9)
    +      elabParamRhsObj6[&member] = rhs;          (x2, both write sites)

    +  auto eit = elabParamRhsObj6.find(&psym);
       if (rit != paramRhsObj.end() && rit->second &&
    +      eit != elabParamRhsObj6.end() && eit->second == rit->second &&
           rit->second->UhdmType() == UHDM::uhdmfunc_call) {

## What it costs: NOTHING measurable

* the implementer's 69-cell grid: report byte-identical, 58/62 MATCH, both binaries
* the verifier's 54 cells: identical on every one except `w_port_conn`
* boundary, 566 files: r10rgg6 vs r10vrgg6 `identical=477 MOVERS=0`
* Rggen database: identical to r10rgg6's except the dump banner
* u2r and surelog rows: 0 differing rows against r10rgg6, both corpora, both modes
