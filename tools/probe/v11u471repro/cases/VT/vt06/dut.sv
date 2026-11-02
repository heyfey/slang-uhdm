// § impTdParamCaFoldTs471
// typedef-typed parameter as a port connection actual and in a net declaration assign
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd6;
endpackage
module sub(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
module top(output logic [3:0] y, output logic [3:0] z);
  import a::*;
  wire [3:0] n = PA;
  sub u(.i(PA), .o(y));
  assign z = n;
endmodule
