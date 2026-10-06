// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
  function automatic m_t inv(m_t a); return ~a; endfunction
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  if (q::inv(8'h00) == 8'hff) begin : g
    assign o = M;
  end else begin : h
    assign o = 8'h0;
  end
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h3c)) u (.o(o));
endmodule
