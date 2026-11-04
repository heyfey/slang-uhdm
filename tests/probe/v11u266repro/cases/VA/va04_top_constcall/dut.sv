// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  localparam logic [7:0] L = q::inv(8'h0f);
  assign p = L;
  sub #(.M(8'h3c)) u (.o(o));
endmodule
