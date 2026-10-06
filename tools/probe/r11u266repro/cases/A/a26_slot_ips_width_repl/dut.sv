// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = 8'h3) (input logic [15:0] x, output logic [15:0] o);
  assign o = {x[0 +: M], {M{1'b1}}};
endmodule
module dut (input logic [15:0] x, output logic [15:0] o);
  sub #(.M(8'h4)) u (.x(x), .o(o));
endmodule
