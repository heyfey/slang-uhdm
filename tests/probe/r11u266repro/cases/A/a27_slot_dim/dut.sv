// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = 8'h3) (output logic [7:0] o);
  logic [M-1:0] w;
  assign w = '1;
  assign o = 8'(w);
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h5)) u (.o(o));
endmodule
