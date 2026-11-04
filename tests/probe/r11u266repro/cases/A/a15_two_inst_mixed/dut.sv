// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = 8'h5) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o, output logic [7:0] o2);
  sub #(.M(8'h3c)) u (.o(o));
  sub u2 (.o(o2));
endmodule
