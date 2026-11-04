// § impTdParamCaFoldTs471
// continuous assignment reads a wildcard-imported typedef parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::*;
  assign y = PA;
endmodule
