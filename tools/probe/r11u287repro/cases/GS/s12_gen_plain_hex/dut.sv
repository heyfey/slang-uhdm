// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; logic [15:0] h; logic [1:0] b; logic [7:0] d; } cfg_t; localparam cfg_t LIT = '{n: 300, h: 16'hBEEF, b: 2'b11, d: 8'd6}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o, output logic [31:0] o2, output logic [7:0] o8);
  if (1) begin : g assign o = CFG.h; end
endmodule
