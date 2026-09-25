// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t XA = 8'h12;
  localparam s_t XB = 8'h34;
endpackage
module leaf #(parameter logic [3:0] V = 0)(); endmodule
module dut #(parameter bit C = 1, parameter pkg::s_t P = C ? pkg::XA : pkg::XB) ();
  leaf #(.V(P.a)) l();
endmodule
module top(); dut d(); endmodule
