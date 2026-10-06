// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module leaf #(parameter q::m_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module sub #(parameter bit E = 1) (output logic [7:0] o);
  if (E) begin : g
    leaf #(.M(8'h7)) l (.o(o));
  end
endmodule
module dut (output logic [7:0] o);
  sub u (.o(o));
endmodule
