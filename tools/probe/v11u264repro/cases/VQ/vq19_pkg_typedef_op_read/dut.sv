// § qualShadowPkgTdKeepsClone264v
package pk;
  typedef logic [7:0] byte_t;
  parameter byte_t NE = 8'd12;
endpackage
module sub(output logic [7:0] o, output logic [7:0] p);
  import pk::*;
  localparam byte_t NE = pk::NE;
  assign o = NE + 1;
  always_comb p = NE;
endmodule
module top(output logic [7:0] o, output logic [7:0] p);
  sub u(.o(o), .p(p));
endmodule
