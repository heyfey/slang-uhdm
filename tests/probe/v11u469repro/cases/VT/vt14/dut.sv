// § importCopyTsInstByRole469
// a module and a sub-instance both import the importing package and read the value through a localparam
package a;
  typedef logic [4:0] t;
  parameter t PA = 5'd11;
endpackage
package b;
  import a::*;
  localparam t LB = PA;
endpackage
module sub #(parameter logic [4:0] Q = 0) (output logic [4:0] o);
  assign o = Q;
endmodule
module top(output logic [4:0] y);
  import b::*;
  sub #(.Q(LB)) u(.o(y));
endmodule
