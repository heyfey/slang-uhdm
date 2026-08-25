// r10v135 (VERIFIER) ARM b7 — HOW THE TOP SEES THE PACKAGE.
// (i) an EXPLICIT single-name import; (ii) NO import at all, the package
// referenced only by `pkg::` scope; (iii) the index class name ALSO being the
// name of a MODULE in the design; (iv) an instance name colliding with it.
package pkgSeeAlfa7;
  class idxBravoCls7; int v; endclass
  class idxCharlieCls7; int v; endclass
  class ownDeltaCls7;
    extern function void oobEcho7();
  endclass
  function void ownDeltaCls7::oobEcho7();
    bit s01Explicit7 [idxBravoCls7];
    bit s02Scoped7   [idxCharlieCls7];
    s01Explicit7.delete();
    s02Scoped7.delete();
  endfunction
endpackage

module topExplFoxtrot7;                 // EXPLICIT single-name imports only
  import pkgSeeAlfa7::ownDeltaCls7;
  ownDeltaCls7 oGolf7;
  initial begin
    oGolf7 = new();
    oGolf7.oobEcho7();
  end
endmodule

module topScopedHotel7;                 // NO import at all
  pkgSeeAlfa7::ownDeltaCls7 oIndia7;
  initial begin
    oIndia7 = new();
    oIndia7.oobEcho7();
  end
endmodule
