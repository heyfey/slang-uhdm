// r10v135 (VERIFIER) ARM b10 — MULTI-DIMENSIONAL and MIXED shapes.
package pkgDimAlfa10;
  class dimBravoCls10;  int v; endclass
  class dimCharlieCls10;int v; endclass
  class dimDeltaCls10;  int v; endclass
  class ownEcho10;
    extern function void oobFoxtrot10();
  endclass
  function void ownEcho10::oobFoxtrot10();
    bit x01TwoCls10   [dimBravoCls10][dimCharlieCls10];  // TWO name dims
    bit x02ClsThenKw10[dimDeltaCls10][string];           // name then KEYWORD
    bit x03KwThenCls10[string][dimBravoCls10];           // KEYWORD then name
    bit x04ClsThenWild10[dimCharlieCls10][*];            // name then WILDCARD
    bit x05Packed10 [7:0][dimDeltaCls10];                // PACKED then name (mixed)
    x01TwoCls10.delete();
    x02ClsThenKw10.delete();
    x03KwThenCls10.delete();
    x04ClsThenWild10.delete();
  endfunction
endpackage

module topDimGolf10;
  import pkgDimAlfa10::*;
  ownEcho10 oHotel10;
  initial begin
    oHotel10 = new();
    oHotel10.oobFoxtrot10();
  end
endmodule
