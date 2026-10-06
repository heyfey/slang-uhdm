// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module leaf #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = 8'h0;
endmodule
module sub #(parameter q::m_t M = 8'h5) (output logic [7:0] o);
  leaf #(.M(M)) l (.o(o));
endmodule
module dut (output logic [7:0] o);
  sub u (.o(o));
endmodule
