// r10v202 arm 3 — FORMALS, RETURN TYPES, STATIC/AUTOMATIC BODY LOCALS, and a
// CLASS-SCOPE typedef declared in the SAME cloned body as a PACKAGE-SCOPE one.
// The verifier's questions:
//   * does the law leave § 36's FORMAL and the RETURN VALUE alone (SITE 1
//     skips `sub.getArguments()` and `sub.returnValVar`)?
//   * does § 198 still own the CLASS-SCOPE typedef when a § 202 cell sits
//     beside it in one body (the two predicates claim to be disjoint)?
//   * do `static` / `automatic` / `const` body locals behave like the plain
//     one?
package quarryV3202;
  class PlainV3202;
    int aV3;
  endclass
  typedef PlainV3202 clsV3202;          // PACKAGE-scope typedef of a class

  class OwnerV3202;
    typedef PlainV3202 clsScopedV3202;  // CLASS-scope typedef -> § 198's domain
    extern function clsV3202 retV3202(clsV3202 argV3);
    extern function void bodyV3202(input clsV3202 inArgV3, output clsV3202 outArgV3);
  endclass

  function clsV3202 OwnerV3202::retV3202(clsV3202 argV3);
    clsV3202        locV3;         // BODY local  -> § 202
    clsScopedV3202  locScopedV3;   // BODY local  -> § 198
    static clsV3202 statLocV3;     // STATIC body local
    locV3       = argV3;
    locScopedV3 = null;
    statLocV3   = null;
    retV3202    = locV3;
  endfunction

  function void OwnerV3202::bodyV3202(input clsV3202 inArgV3, output clsV3202 outArgV3);
    automatic clsV3202 autoLocV3;
    begin
      clsV3202       blkLocV3;
      clsScopedV3202 blkScopedV3;
      blkLocV3    = inArgV3;
      blkScopedV3 = null;
      autoLocV3   = blkLocV3;
    end
    outArgV3 = autoLocV3;
  endfunction
endpackage

package sluiceV3202;
  import quarryV3202::*;
  class FlumeV3202;
    function void raceV3202();
      OwnerV3202 gateV3;
      gateV3 = null;
    endfunction
  endclass
endpackage
