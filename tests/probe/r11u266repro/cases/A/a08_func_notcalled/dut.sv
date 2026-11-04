// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic int cnt(m_t a); return a; endfunction
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3c)) u (.o(o));
endmodule
