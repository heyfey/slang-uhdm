// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; logic [7:0] d; logic signed [7:0] s; } cfg_t; localparam cfg_t LIT = '{n: 300, d: 8'd6, s: 8'sd3}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (input logic [7:0] a, output logic [15:0] o, output logic [7:0] z);
  if (1) begin : g assign o[15:8] = CFG.d; assign o[7:0] = CFG.d; end
  assign z = a + CFG.d;
endmodule
