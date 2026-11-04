// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module s1 #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module s2 #(parameter q::m_t N = '0) (output logic [7:0] o);
  assign o = q::inv(N);
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  s1 #(.M(8'h3c)) u1 (.o(o));
  s2 #(.N(8'h11)) u2 (.o(p));
endmodule
