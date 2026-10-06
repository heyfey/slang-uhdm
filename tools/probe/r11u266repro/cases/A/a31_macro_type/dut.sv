// § pkgTdParamValListingTs266
`define QT q::m_t
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter `QT M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3c)) u (.o(o));
endmodule
