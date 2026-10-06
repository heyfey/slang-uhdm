// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  localparam logic [7:0] L = 8'h3c;
  sub #(.M(L)) u (.o(o));
endmodule
