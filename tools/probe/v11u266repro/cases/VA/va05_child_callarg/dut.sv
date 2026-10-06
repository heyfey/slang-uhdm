// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module leaf #(parameter q::m_t X = '0) (output logic [7:0] o);
  assign o = q::inv(X);
endmodule
module sub #(parameter q::m_t M = '0) (output logic [7:0] o, output logic [7:0] p);
  assign p = M;
  leaf #(.X(M)) l (.o(o));
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  sub #(.M(8'h3c)) u (.o(o), .p(p));
endmodule
