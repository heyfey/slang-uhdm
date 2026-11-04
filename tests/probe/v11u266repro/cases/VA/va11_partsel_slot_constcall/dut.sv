// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module sub #(parameter q::m_t M = 8'h04) (input logic [15:0] i, output logic [7:0] o, output logic [3:0] p);
  assign o = i[M+:8];
  localparam logic [7:0] K = q::inv(8'hfe);
  assign p = K[3:0];
endmodule
module dut (input logic [15:0] i, output logic [7:0] o, output logic [3:0] p);
  sub #(.M(8'h02)) u (.i(i), .o(o), .p(p));
endmodule
