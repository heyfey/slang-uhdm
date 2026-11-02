// § pkgInitImpReadFolds471
// a typedef-typed imported parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd5;
endpackage
package b;
  import a::*;
  localparam t LB = PA;
endpackage
module top;
  logic w;
endmodule
