// § pkgReadRefChainLitForm475
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd33;
  parameter t PB = PA;
endpackage
module sub #(parameter logic [5:0] Q = 0) (output logic [5:0] o);
  assign o = Q;
endmodule
module top(output logic [5:0] y, output logic [5:0] z, output logic [6:0] w);
  import a::*;
  logic [5:0] v = PB;
  sub #(.Q(PB)) u(.o(y));
  assign z = PB + 6'd1;
  assign w = {1'b0, PB};
endmodule
