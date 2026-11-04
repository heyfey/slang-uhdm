// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module dut #(parameter q::m_t M = 8'h5) (output logic [7:0] o);
  assign o = 8'h0;
endmodule
