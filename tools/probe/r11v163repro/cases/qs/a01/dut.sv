// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t XV = '{a: 4'h1, b: 4'h2};
endpackage
module leaf #(parameter logic [3:0] V = 0)(); endmodule
module dut #(parameter pkg::s_t P = pkg::XV) ();
  leaf #(.V(P.b)) l();
endmodule
module top(); dut d(); endmodule
