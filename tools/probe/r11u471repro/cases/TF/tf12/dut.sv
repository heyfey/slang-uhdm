// § impTdParamCaFoldTs471
// signed typedef parameter in a concatenation
package a;
  typedef logic signed [3:0] st;
  parameter st PS = -4'sd3;
endpackage
module top(output logic [7:0] y);
  import a::*;
  assign y = {PS, 4'h0};
endmodule
