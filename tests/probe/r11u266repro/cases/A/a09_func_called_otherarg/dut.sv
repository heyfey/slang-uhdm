// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module sub #(parameter q::m_t M = '0) (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  assign o = M;
  assign p = q::inv(i);
endmodule
module dut (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  sub #(.M(8'h3c)) u (.i(i), .o(o), .p(p));
endmodule
