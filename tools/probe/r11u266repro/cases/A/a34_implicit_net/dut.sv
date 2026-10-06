// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = '0) ();
  assign w = M[0];
endmodule
module dut ();
  sub #(.M(8'h3c)) u ();
endmodule
