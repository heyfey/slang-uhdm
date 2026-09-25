// § aggParamFoldQualSpanByView163
package pa;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'h1234;
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module dut #(parameter pa::s_t P = pa::XLONG, parameter pa::s_t Q = P) ();
  leaf #(.V(Q.a)) l();
endmodule
module top(); dut d(); endmodule
