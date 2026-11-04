// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'h1234;
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module dut ();
  localparam pkg::s_t L = pkg::XLONG;
  leaf #(.V(L.b)) l();
endmodule
module top(); dut d(); endmodule
