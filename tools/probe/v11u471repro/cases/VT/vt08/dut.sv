// § impTdParamCaFoldTs471
// typedef-typed imported parameter as a net declaration initializer only
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd6;
endpackage
module top(output logic [3:0] z);
  import a::*;
  wire [3:0] n = PA;
  assign z = n;
endmodule
