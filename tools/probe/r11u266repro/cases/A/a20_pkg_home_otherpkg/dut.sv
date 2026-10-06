// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
package r;
  parameter q::m_t RM = 8'h21;
endpackage
module dut import r::*; (output logic [7:0] o);
  assign o = RM;
endmodule
