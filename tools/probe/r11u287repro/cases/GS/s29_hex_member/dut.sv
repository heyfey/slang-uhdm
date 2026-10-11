// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { logic [15:0] h; } cfg_t; localparam cfg_t LIT = '{h: 16'hBEEF}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g assign o[15:0] = CFG.h; end
endmodule
