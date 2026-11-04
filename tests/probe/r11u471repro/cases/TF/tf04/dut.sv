// § impTdParamCaFoldTs471
// operand of a binary operation
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module top(input logic [3:0] i, output logic [3:0] y);
  import a::*;
  assign y = i ^ PA;
endmodule
