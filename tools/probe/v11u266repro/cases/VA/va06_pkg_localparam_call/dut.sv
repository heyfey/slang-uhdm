// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
  localparam m_t Z = inv(8'h0f);
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o, output logic [7:0] p);
  assign o = M;
  assign p = q::Z;
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  sub #(.M(8'h3c)) u (.o(o), .p(p));
endmodule
