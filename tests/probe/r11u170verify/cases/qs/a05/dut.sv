// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'hBEEF;
endpackage
module leaf #(parameter logic [7:0] V = 0) (output logic [7:0] o); assign o = V; endmodule
module mid #(parameter logic [7:0] W = 0) (output logic [7:0] o); leaf #(.V(W)) l(.o(o)); endmodule
module dut #(parameter pkg::s_t P = pkg ::  XLONG) (output logic [7:0] o);
  mid #(.W(P.b)) m(.o(o));
endmodule
module top (output logic [7:0] o); dut d(.o(o)); endmodule
