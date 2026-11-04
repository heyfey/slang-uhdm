// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  localparam m_t D = 8'h11;
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(q::D)) u (.o(o));
endmodule
