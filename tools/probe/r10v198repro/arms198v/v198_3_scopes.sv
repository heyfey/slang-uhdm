// r10v198 arm 3 — DECLARING SCOPES the implementer's grid did not vary in this
// combination: a NESTED class, a PARAMETERISED class (both the default and an
// explicit specialisation), a typedef INHERITED from a base class declared in
// ANOTHER package, and a TRANSITIVE import chain (three packages deep), where
// the home the instance must name is the class's DECLARING package and not the
// package the importer names.
package baseP3;
  class RootV3;
    typedef struct { int rootAV3; string rootBV3; } rootStV3;   // inherited below
    typedef int rootIntV3;
  endclass
endpackage
package midP3;
  import baseP3::*;
  typedef struct { int mpA; } midPkgStV3;                        // CONTROL package struct
  class OuterV3 extends RootV3;
    typedef struct { int outAV3; } outStV3;
    class InnerV3;                                               // NESTED class
      typedef struct { int inAV3; } innStV3;
    endclass
    extern function void bearV3();
  endclass
  class ParamV3 #(parameter int WV3 = 4);
    typedef struct { bit [WV3-1:0] pwV3; } parStV3;
    extern function void spinV3();
  endclass
  function void OuterV3::bearV3();
    outStV3          tfOutV3;        // own class typedef
    rootStV3         tfRootV3;       // INHERITED from a base class in ANOTHER package
    rootIntV3        tfRootIntV3;    // inherited int
    InnerV3::innStV3 tfInnV3;        // two-segment spelling naming a NESTED class
    midPkgStV3       tfMidPkgV3;     // CONTROL: package struct
    begin
      outStV3          blkOutV3;
      rootStV3         blkRootV3;
      InnerV3::innStV3 blkInnV3;
      midPkgStV3       blkMidPkgV3;
      blkOutV3.outAV3 = 0; blkRootV3.rootAV3 = 0;
      blkInnV3.inAV3 = 0;  blkMidPkgV3.mpA = 0;
    end
    tfOutV3.outAV3 = 0; tfRootV3.rootAV3 = 0; tfRootIntV3 = 0;
    tfInnV3.inAV3 = 0;  tfMidPkgV3.mpA = 0;
  endfunction
  function void ParamV3::spinV3();
    parStV3    tfParV3;       // typedef of a PARAMETERISED class
    midPkgStV3 tfParPkgV3;    // CONTROL
    begin
      parStV3 blkParV3;
      blkParV3.pwV3 = 0;
    end
    tfParV3.pwV3 = 0;
    tfParPkgV3.mpA = 0;
  endfunction
endpackage
package leafP3;                    // TRANSITIVE: leafP3 -> midP3 -> baseP3
  import midP3::*;
  class HaulV3;
    function void dragV3();
      OuterV3 oV3;
      oV3 = null;
    endfunction
  endclass
endpackage
