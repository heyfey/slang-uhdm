// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'd4660;
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module dut #(parameter pkg::s_t P = pkg::XLONG) ();
  leaf #(.V(P.a)) l();
endmodule
module top(); dut d(); endmodule
