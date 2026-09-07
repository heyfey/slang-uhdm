// r10uvm189 arm A — INDEX KINDS x LISTING.  One home package, one wildcard
// importer, one top module; the SAME seven index spellings in an OUT-OF-BODY
// class method's body, an IN-BODY class method's body and a free package
// function's body, so the KEYWORD / NAME split and the listing axis are read
// off ONE golden.  Names are arm-local so nothing collides with another arm.
package Girder189;
  class Trellis189;
    int nodeA189;
  endclass
  typedef Trellis189 tdTrellisA189;
  typedef int tdIntA189;
  typedef enum { LOFTA189, SPANA189 } enKindA189;

  class Purlin189;
    extern function void weaveA189();
    function void inbodyA189();
      bit inbClsA189[Trellis189];
      bit inbStrA189[string];
      inbClsA189[null] = 1'b1;
      inbStrA189["k"] = 1'b0;
    endfunction
  endclass

  function void Purlin189::weaveA189();
    bit oobClsA189[Trellis189];
    bit oobTdClsA189[tdTrellisA189];
    bit oobStrA189[string];
    bit oobIntA189[int];
    bit oobWildA189[*];
    bit oobEnumA189[enKindA189];
    bit oobTdIntA189[tdIntA189];
    oobClsA189[null] = 1'b1;
    oobTdClsA189[null] = 1'b1;
    oobStrA189["a"] = 1'b1;
    oobIntA189[3] = 1'b1;
    oobWildA189[7] = 1'b1;
    oobEnumA189[LOFTA189] = 1'b1;
    oobTdIntA189[5] = 1'b1;
  endfunction

  function void freeWeaveA189();
    bit frClsA189[Trellis189];
    bit frStrA189[string];
    bit frIntA189[int];
    frClsA189[null] = 1'b1;
    frStrA189["z"] = 1'b0;
    frIntA189[2] = 1'b1;
  endfunction
endpackage

package Mullion189;
  import Girder189::*;
  function void callerA189();
    Purlin189 pA189;
    pA189 = new();
    pA189.weaveA189();
    pA189.inbodyA189();
    freeWeaveA189();
  endfunction
endpackage

module topGirder189;
  import Mullion189::*;
  initial callerA189();
endmodule
