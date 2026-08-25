// r10v135 (VERIFIER) ARM b3 — NAME COLLISIONS IN THE IMPORTING TOP.
// Five class names used as associative indices in a package OOB method; the
// top declares each name ALSO as something else.  MUST NOT DUPLICATE.
package pkgCollAlpha3;
  class cNetHotel3;    int v; endclass
  class cVarIndia3;    int v; endclass
  class cParamJuliett3;int v; endclass
  class cLparamKilo3;  int v; endclass
  class cFreeLima3;    int v; endclass
  class cTwiceMike3;   int v; endclass

  class ownerNovem3;
    extern function void collOscar3();
  endclass

  function void ownerNovem3::collOscar3();
    bit d01NetName3   [cNetHotel3];
    bit d02VarName3   [cVarIndia3];
    bit d03ParamName3 [cParamJuliett3];
    bit d04LparamName3[cLparamKilo3];
    // TWO arrays, the SAME index class: ONE wire or TWO?
    bit d05TwiceA3    [cTwiceMike3];
    bit d06TwiceB3    [cTwiceMike3];
    d01NetName3.delete();
    d02VarName3.delete();
    d03ParamName3.delete();
    d04LparamName3.delete();
    d05TwiceA3.delete();
    d06TwiceB3.delete();
  endfunction

  function void freePapa3();
    bit d07FreeLocal3 [cFreeLima3];
    d07FreeLocal3.delete();
  endfunction
endpackage

module topCollQuebec3;
  import pkgCollAlpha3::*;
  wire  cNetHotel3;                       // the name is ALSO a NET here
  logic cVarIndia3;                       // the name is ALSO a VARIABLE here
  parameter int cParamJuliett3 = 3;       // the name is ALSO a PARAMETER here
  localparam int cLparamKilo3  = 4;       // the name is ALSO a LOCALPARAM here
  wire  cFreeLima3;                       // a NET colliding with the FREE fn's
  ownerNovem3 oRomeoColl3;
  initial begin
    oRomeoColl3 = new();
    oRomeoColl3.collOscar3();
    freePapa3();
  end
endmodule
