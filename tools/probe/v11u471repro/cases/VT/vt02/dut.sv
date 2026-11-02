// § impTdParamCaFoldTs471
// typedef-typed parameter in a select index and in a part-select operand
package a;
  typedef logic [2:0] i_t;
  parameter i_t PI = 3'd2;
endpackage
module top(input logic [7:0] x, output logic y, output logic [3:0] z);
  import a::*;
  assign y = x[PI];
  assign z = x[PI +: 4];
endmodule
