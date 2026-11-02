// § procAsgRhsPkgFoldTs471
// always_comb, typedef parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::*;
  always_comb y = PA;
endmodule
