// § pkgExportItemReImports471
// typedef parameter re-exported, a module reads it through b (downstream)
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd33;
endpackage
package b;
  import a::*;
  export a::*;
  localparam t LB = PA;
endpackage
module top(output logic [5:0] y);
  import b::*;
  assign y = PA;
endmodule
