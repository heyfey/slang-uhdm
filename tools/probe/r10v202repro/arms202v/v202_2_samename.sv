// r10v202 arm 2 — SAME TYPEDEF NAME IN TWO DIFFERENT PACKAGES, and a THIRD
// package's typedef, cloned into THREE different importers (one of which
// wildcard-imports BOTH homes).  The verifier's question: is the NAME the
// written one and is the INSTANCE the CLONED METHOD'S HOME (not the typedef's
// home and not the importer)?  A wrong stamp here is judge-visible —
// `typespec::Compare` reads VpiName and Instance.
package thirdV2202;
  class ThirdClsV2202;
    int tV2;
  endclass
  typedef ThirdClsV2202 thirdTdV2202;
endpackage

package alphaV2202;
  import thirdV2202::*;
  class CAV2202;
    int xV2;
  endclass
  typedef CAV2202      dupTdV2202;   // SAME NAME as beta's, DIFFERENT target
  typedef ThirdClsV2202 farTdV2202;  // a typedef of a THIRD package's class

  class HolderAV2202;
    extern function void mAV2202();
  endclass
  function void HolderAV2202::mAV2202();
    dupTdV2202  tfDupAV2;
    farTdV2202  tfFarAV2;
    begin
      dupTdV2202 blkDupAV2;
      farTdV2202 blkFarAV2;
      blkDupAV2 = null;
      blkFarAV2 = null;
    end
    tfDupAV2 = null;
    tfFarAV2 = null;
  endfunction
endpackage

package betaV2202;
  class CBV2202;
    int yV2;
  endclass
  typedef CBV2202 dupTdV2202;        // the SAME typedef NAME, other package

  class HolderBV2202;
    extern function void mBV2202();
  endclass
  function void HolderBV2202::mBV2202();
    dupTdV2202 tfDupBV2;
    begin
      dupTdV2202 blkDupBV2;
      blkDupBV2 = null;
    end
    tfDupBV2 = null;
  endfunction
endpackage

package impAV2202;                    // imports ALPHA only
  import alphaV2202::*;
  class UAV2202;
    function void fAV2();
      HolderAV2202 hA;
      hA = null;
    endfunction
  endclass
endpackage

package impBV2202;                    // imports BETA only
  import betaV2202::*;
  class UBV2202;
    function void fBV2();
      HolderBV2202 hB;
      hB = null;
    endfunction
  endclass
endpackage

package impBothV2202;                 // imports BOTH homes: two clones, one listing
  import alphaV2202::*;
  import betaV2202::*;
  class UBothV2202;
    function void fBothV2();
      HolderAV2202 hA2;
      HolderBV2202 hB2;
      hA2 = null;
      hB2 = null;
    endfunction
  endclass
endpackage
