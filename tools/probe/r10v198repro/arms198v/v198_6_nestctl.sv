// r10v198 arm 6 — arm 3 with EVERY class-scope typedef LOCAL removed.  Nothing
// in this file can reach either patched site, so any head it produces is
// PRE-EXISTING and the two binaries must be byte-identical on it.
package baseP6;
  class RootV6;
    typedef struct { int rootAV6; string rootBV6; } rootStV6;
    typedef int rootIntV6;
  endclass
endpackage
package midP6;
  import baseP6::*;
  typedef struct { int mpA; } midPkgStV6;
  class OuterV6 extends RootV6;
    typedef struct { int outAV6; } outStV6;
    class InnerV6;
      typedef struct { int inAV6; } innStV6;
    endclass
    extern function void bearV6();
  endclass
  function void OuterV6::bearV6();
    midPkgStV6 tfMidPkgV6;
    begin
      midPkgStV6 blkMidPkgV6;
      blkMidPkgV6.mpA = 0;
    end
    tfMidPkgV6.mpA = 0;
  endfunction
endpackage
package leafP6;
  import midP6::*;
  class HaulV6;
    function void dragV6();
      OuterV6 oV6;
      oV6 = null;
    endfunction
  endclass
endpackage
