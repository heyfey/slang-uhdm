// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module sub #(parameter q::m_t M = '0, parameter q::m_t N = '1) (output logic [7:0] o, output logic [7:0] p);
  assign o = M;
  assign p = q::inv(N);
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  sub #(.M(8'h3c), .N(8'h11)) u (.o(o), .p(p));
endmodule
