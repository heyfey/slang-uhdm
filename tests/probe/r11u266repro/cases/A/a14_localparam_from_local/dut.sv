// § pkgTdParamValListingTs266
package q;
  typedef logic [7:0] m_t;
endpackage
module sub (output logic [7:0] o);
  localparam logic [7:0] L = 8'h3;
  localparam q::m_t M = L;
  assign o = 8'h0;
endmodule
module dut (output logic [7:0] o);
  sub u (.o(o));
endmodule
