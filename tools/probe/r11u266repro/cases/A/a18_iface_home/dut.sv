// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
interface ifc #(parameter q::m_t M = '0);
  logic [7:0] w;
  assign w = M;
endinterface
module dut (output logic [7:0] o);
  ifc #(.M(8'h3c)) i0 ();
  assign o = i0.w;
endmodule
