// § aggParamFoldQualSpanByView163
typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
localparam s_t XLONG = 16'h1234;
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module dut #(parameter s_t P = $unit::XLONG) ();
  leaf #(.V(P.a)) l();
endmodule
module top(); dut d(); endmodule
