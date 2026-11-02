// § impTdParamCaFoldTs471
// typedef-typed imported parameter as a port connection actual only
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd6;
endpackage
module sub(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
module top(output logic [3:0] y);
  import a::*;
  sub u(.i(PA), .o(y));
endmodule
