// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] b_t;
  typedef b_t m_t;
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3c)) u (.o(o));
endmodule
