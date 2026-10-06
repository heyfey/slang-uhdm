// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic int w(m_t a); return a + 1; endfunction
endpackage
module sub #(parameter q::m_t M = 8'h3) (output logic [7:0] o);
  logic [q::w(M | 8'h0)-1:0] v;
  assign v = '1;
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3)) u (.o(o));
endmodule
