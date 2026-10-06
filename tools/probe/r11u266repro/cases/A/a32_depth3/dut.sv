// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module leaf #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module mid #(parameter q::m_t M = '0) (output logic [7:0] o);
  leaf #(.M(M ^ 8'h1)) l (.o(o));
endmodule
module dut (output logic [7:0] o);
  mid #(.M(8'h3c)) m (.o(o));
endmodule
