// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module sub #(parameter int W = 2) (output logic [7:0] o, output logic [7:0] p);
  localparam q::m_t L = 8'h3c;
  localparam logic [7:0] K = q::inv(8'h0f);
  assign o = L;
  assign p = K;
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  sub u (.o(o), .p(p));
endmodule
