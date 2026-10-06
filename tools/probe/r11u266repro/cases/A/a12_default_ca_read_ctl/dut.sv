// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = 8'h5) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub u (.o(o));
endmodule
