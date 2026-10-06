// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.M(8'h3c + i)) u (.o(o[i]));
  end
endmodule
